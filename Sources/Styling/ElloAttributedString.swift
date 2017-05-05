////
///  ElloAttributedString.swift
//

let ParagraphAlignmentAttributeName = "ParagraphAlignmentAttributeName"

struct ElloAttributedString {
    fileprivate struct HtmlTagTuple {
        let tag: String
        let attributes: String?

        init(_ tag: String, attributes: String? = nil) {
            self.tag = tag
            self.attributes = attributes
        }
    }

    static func attrs(_ allAddlAttrs: [String: Any]...) -> [String: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        var attrs: [String: Any] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.black,
        ]
        for addlAttrs in allAddlAttrs {
            attrs += addlAttrs
        }
        return attrs
    }

    static func linkAttrs() -> [String: Any] {
        return attrs([
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
        ])
    }

    static func split(_ text: NSAttributedString, split: String = "\n") -> [NSAttributedString] {
        var strings = [NSAttributedString]()
        var current = NSMutableAttributedString()
        var hasLetters = false
        var startNewString = false
        let nsCount = (text.string as NSString).length
        for i in 0..<nsCount {
            let letter = NSMutableAttributedString(attributedString: text)
            if i < nsCount - 1 {
                letter.deleteCharacters(in: NSRange(location: i + 1, length: nsCount - i - 1))
            }
            if i > 0 {
                letter.deleteCharacters(in: NSRange(location: 0, length: i))
            }

            if letter.string == "\n" {
                current.append(letter)
                startNewString = true
            }
            else {
                if !startNewString {
                    hasLetters = true
                }
                else if hasLetters {
                    strings.append(current)
                    current = NSMutableAttributedString()
                }
                current.append(letter)
                startNewString = false
            }
        }
        if current.string.characters.count > 0 {
            strings.append(current)
        }
        return strings
    }

    static func style(_ text: String, _ addlAttrs: [String: Any] = [:]) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs(addlAttrs))
    }

    static func parse(_ input: String) -> NSAttributedString? {
        if let tag = Tag(input: input) {
            return tag.makeEditable(attrs())
        }
        return nil
    }

    static func render(_ input: NSAttributedString) -> String {
        var output = ""
        input.enumerateAttributes(in: NSRange(location: 0, length: input.length), options: .longestEffectiveRangeNotRequired) { attrs, range, stopPtr in
            // (tagName, attributes?)
            var tags = [HtmlTagTuple]()
            if let underlineStyle = attrs[NSUnderlineStyleAttributeName] as? Int, underlineStyle == NSUnderlineStyle.styleSingle.rawValue {
                tags.append(HtmlTagTuple("u"))
            }

            if let font = attrs[NSFontAttributeName] as? UIFont {
                if font.fontName == UIFont.editorBoldFont().fontName {
                    tags.append(HtmlTagTuple("strong"))
                }
                else if font.fontName == UIFont.editorBoldItalicFont().fontName {
                    tags.append(HtmlTagTuple("strong"))
                    tags.append(HtmlTagTuple("em"))
                }
                else if font.fontName == UIFont.editorItalicFont().fontName {
                    tags.append(HtmlTagTuple("em"))
                }
            }

            if let link = attrs[NSLinkAttributeName] as? URL {
                tags.append(HtmlTagTuple("a", attributes: "href=\"\(link.absoluteString.entitiesEncoded())\""))
            }

            for htmlTag in tags {
                output += "<\(htmlTag.tag)"
                if let attrs = htmlTag.attributes {
                    output += " "
                    output += attrs
                }
                output += ">"
            }
            output += (input.string as NSString).substring(with: range).entitiesEncoded()
            for htmlTag in tags.reversed() {
                output += "</\(htmlTag.tag)>"
            }
        }
        return output
    }

    static func featuredIn(categories: [Category], attrs: [String: Any] = [:]) -> NSAttributedString {
        let defaultAttributes = featuredInAttrs(attrs)
        var featuredIn = NSAttributedString(string: InterfaceString.Profile.FeaturedIn, attributes: featuredInAttrs(defaultAttributes, attrs))

        let count = categories.count
        for (index, category) in categories.enumerated() {
            let prefix: NSAttributedString
            if index == count - 1 && count > 1 {
                prefix = NSAttributedString(string: " & ", attributes: defaultAttributes)
            }
            else if index > 0 {
                prefix = NSAttributedString(string: ", ", attributes: defaultAttributes)
            }
            else {
                prefix = NSAttributedString(string: " ", attributes: defaultAttributes)
            }
            featuredIn = featuredIn.appending(prefix)
                .appending(style(category: category, attrs: attrs))
        }

        return featuredIn
    }

    private static func featuredInAttrs(_ allAddlAttrs: [String: Any]...) -> [String: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center

        var attrs: [String: Any] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.defaultFont(18),
            NSForegroundColorAttributeName: UIColor.white,
        ]
        for addlAttrs in allAddlAttrs {
            attrs += addlAttrs
        }

        if let alignmentInt = attrs[ParagraphAlignmentAttributeName] as? Int,
            let alignment = NSTextAlignment(rawValue: alignmentInt)
        {
            paragraphStyle.alignment = alignment
        }

        return attrs
    }

    private static func style(category: Category, attrs: [String: Any]) -> NSAttributedString {
        return NSAttributedString(string: category.name, attributes: featuredInAttrs([
            ElloAttributedText.Link: "category",
            ElloAttributedText.Object: category,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
        ], attrs))
    }
}
