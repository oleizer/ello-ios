////
///  ProfileCategoriesProtocols.swift
//

protocol ProfileCategoriesDelegate: class {
    func learnMoreTapped()
    func categoryTapped(_ category: Category)
    func dismiss()
}

protocol ProfileCategoriesProtocol: class {
}
