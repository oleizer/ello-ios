////
///  ConversationViewController.swift
//

import JSQMessagesViewController
import Birdsong
import PINRemoteImage
import PINCache

public class ConversationViewController: JSQMessagesViewController, ControllerThatMightHaveTheCurrentUser {

    public var currentUser: User?
    public var elloNavigationItem = UINavigationItem()
    private var navigationBar: ElloNavigationBar!
    private var messages = [JSQMessage]()
    private var localMessages = [JSQMessage]()
    private var conversation: Conversation?
    private var incomingBubble: JSQMessagesBubbleImage!
    private var outgoingBubble: JSQMessagesBubbleImage!
    private var avatars: [String: JSQMessagesAvatarImage] = [:]

    private var channel: Channel?


    public convenience init(conversation: Conversation) {
        self.init()
        self.conversation = conversation
        title = conversation.name
        elloNavigationItem.title = title

        if let websocket = WebSocket {
            channel = websocket.channel("v1:conversation:\(conversation.id)")
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupAvatars()
        inputToolbar.contentView?.leftBarButtonItem = nil
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )


        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false

        automaticallyScrollsToMostRecentMessage = true

        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()

        connectToConversation()

    }

    private func connectToConversation() {
        guard let
            channel = self.channel
        else { return }

        channel.on("messages", callback: { message in
            self.addMessages(message)
        })

        channel.on("ping", callback: { response in
            print("ping called")
        })

        channel.join().receive("ok", callback: { payload in
            print("Successfully joined: \(channel.topic)")
        })
    }

    private func addMessages(response: Response) {
        guard let
            newMessages = response.payload["messages"] as? [[String: AnyObject]]
        else { return }

        for message in newMessages.reverse() {
            guard let
                elloMessage = Message.fromJSON(message) as? Message,
                name = elloMessage.author?.username,
                senderId = elloMessage.author?.userId
            else { continue }

            let jsMessage = JSQMessage(senderId: senderId, displayName: name, text: elloMessage.body)
            if !self.localMessages.contains( { $0.senderId == senderId && $0.text == elloMessage.body }) {
                self.messages.append(jsMessage)
            }
            else {
                self.localMessages = self.localMessages.filter({ $0.senderId != senderId && $0.text != elloMessage.body })
            }
        }
        self.finishReceivingMessageAnimated(true)
    }



    // MARK: JSQMessagesViewController method overrides
    override public func didPressSendButton(
        button: UIButton,
        withMessageText text: String,
        senderId: String,
        senderDisplayName: String,
        date: NSDate) {
        channel?.send("new_message", payload: ["body": text])
            .receive("ok", callback: { response in
                print("Sent a message!")
            })
            .receive("error", callback: { reason in
                print("Message didn't send: \(reason)")
            })

        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.localMessages.append(message)
        self.messages.append(message)
        self.finishSendingMessageAnimated(true)
    }

    //MARK: JSQMessages CollectionView DataSource

    override public func senderId() -> String {
        return currentUser?.id ?? ""
    }

    override public func senderDisplayName() -> String {
        return currentUser?.username ?? ""
    }

    override public func collectionView(
        collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override public func collectionView(
        collectionView: JSQMessagesCollectionView,
        messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }

    override public func collectionView(
        collectionView: JSQMessagesCollectionView,
        messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {

        return messages[indexPath.item].senderId == self.senderId() ? outgoingBubble : incomingBubble
    }

    override public func collectionView(
        collectionView: JSQMessagesCollectionView,
        avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = messages[indexPath.item]
        return avatars[message.senderId]
    }

    override public func collectionView(
        collectionView: JSQMessagesCollectionView,
        attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]

            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }

        return nil
    }

    override public func collectionView(
        collectionView: JSQMessagesCollectionView,
        attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]

        if message.senderId == self.senderId() {
            return nil
        }

        return NSAttributedString(string: message.senderDisplayName)
    }

    override public func collectionView(
        collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }

        return 0.0
    }

    override public func collectionView(
        collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]

        if currentMessage.senderId == self.senderId() {
            return 0.0
        }

        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    @IBAction func backTapped(sender: UIButton) {
        inForeground {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

extension ConversationViewController {

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
        view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: #selector(backTapped(_:)))
        elloNavigationItem.leftBarButtonItems = [item]
        elloNavigationItem.fixNavBarItemPadding()
        navigationBar.items = [elloNavigationItem]

    }

    private func setupAvatars() {
        guard let
            currentUser = currentUser,
            members = conversation?.members
        else { return }

        let factory = JSQMessagesAvatarImageFactory()

        avatars[currentUser.id] = JSQMessagesAvatarImage(placeholder: InterfaceImage.CircBig.normalImage)

        for member in members where member.id != currentUser.id {
            loadUserAvatar(member, avatarFactory: factory)
        }

        loadCurrentUserAvatar(currentUser, avatarFactory: factory)
    }

    private func loadCurrentUserAvatar(
        currentUser: User,
        avatarFactory: JSQMessagesAvatarImageFactory) {

        if let url = currentUser.avatarURL() {
            let manager = PINRemoteImageManager.sharedImageManager()
            manager.downloadImageWithURL(url) { result in
                let image = avatarFactory.circularAvatarImage(result.image)
                self.avatars[currentUser.id] =
                    JSQMessagesAvatarImage(
                        avatarImage: image,
                        highlightedImage: result.image,
                        placeholderImage: InterfaceImage.CircBig.normalImage)
                self.collectionView?.reloadData()
            }
        }
    }

    private func loadUserAvatar(
        member: ConversationMember,
        avatarFactory: JSQMessagesAvatarImageFactory) {

        let manager = PINRemoteImageManager.sharedImageManager()
        avatars[member.userId] = JSQMessagesAvatarImage(placeholder: InterfaceImage.CircBig.normalImage)

        StreamService().loadUser(
            ElloAPI.UserStream(userParam: member.userId),
            streamKind: nil,
            success: { [weak self] (user, _) in
                guard let
                    sself = self,
                    avatarURL = user.avatarURL()
                    else { return }
                manager.downloadImageWithURL(avatarURL) { result in
                    let image = avatarFactory.circularAvatarImage(result.image)
                    sself.avatars[member.userId] =
                        JSQMessagesAvatarImage(
                            avatarImage: image,
                            highlightedImage: image,
                            placeholderImage: InterfaceImage.CircBig.normalImage)
                    sself.collectionView?.reloadData()
                }
            },
            failure: {_, _ in })
    }
}
