//
//  CarPlaySceneDelegate.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-05-27.
//

import CarPlay

class CarPlaySceneDelegate: UIResponder, UIWindowSceneDelegate, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let carPlayScene = scene as? CPTemplateApplicationScene else {
            return
        }
        carPlayScene.delegate = self
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController

        // Set up the initial template
        setupInitialTemplate()
    }

    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    private func setupInitialTemplate() {
        let item1 = CPListItem(text: "Hello", detailText: "World")
        let item2 = CPListItem(text: "Swift", detailText: "UI")

        item1.handler = { [weak self] item, completion in
            self?.showDetailTemplate(title: item1.text, detail: item1.detailText)
            completion()
        }

        item2.handler = { [weak self] item, completion in
            self?.showDetailTemplate(title: item2.text, detail: item2.detailText)
            completion()
        }

        let listSection = CPListSection(items: [item1, item2])
        let listTemplate = CPListTemplate(title: "My CarPlay App", sections: [listSection])

        interfaceController?.setRootTemplate(listTemplate, animated: true, completion: { _, _ in
            print("Root template set")
        })
    }

    private func showDetailTemplate(title: String?, detail: String?) {
        let item = CPListItem(text: title ?? "", detailText: detail ?? "")
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: title ?? "", sections: [section])

        interfaceController?.pushTemplate(listTemplate, animated: true, completion: { _, _ in
            print("Detail template pushed")
        })
    }
}
