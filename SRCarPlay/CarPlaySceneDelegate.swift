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

        let item = CPListItem(text: "Hello", detailText: "World")
        let listTemplate = CPListTemplate(title: "Hello World", sections: [CPListSection(items: [item])])

        interfaceController.setRootTemplate(listTemplate, animated: true)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
}

