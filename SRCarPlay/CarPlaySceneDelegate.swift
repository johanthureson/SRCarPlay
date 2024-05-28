//
//  CarPlaySceneDelegate.swift
//  SRCarPlay
//

import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        setupInitialTemplate()
    }

    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    private func setupInitialTemplate() {
        let poddarTemplate = createPoddarTemplate()
        let nyheterTemplate = createNyheterTemplate()
        let kanalerTemplate = createKanalerTemplate()
        let minSidaTemplate = createMinSidaTemplate()

        let tabBarTemplate = CPTabBarTemplate(templates: [poddarTemplate, nyheterTemplate, kanalerTemplate, minSidaTemplate])

        interfaceController?.setRootTemplate(tabBarTemplate, animated: true, completion: { _, _ in
            print("Root template set")
        })
    }

    private func createPoddarTemplate() -> CPTemplate {
        let item = CPListItem(text: "Podcast 1", detailText: nil)
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Poddar", sections: [section])
        listTemplate.tabImage = UIImage(systemName: "headphones")
        return listTemplate
    }

    private func createNyheterTemplate() -> CPTemplate {
        let item = CPListItem(text: "News 1", detailText: nil)
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Nyheter", sections: [section])
        listTemplate.tabImage = UIImage(systemName: "doc.text")
        return listTemplate
    }

    private func createKanalerTemplate() -> CPTemplate {
        let item = CPListItem(text: "Channel 1", detailText: nil)
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Kanaler", sections: [section])
        listTemplate.tabImage = UIImage(systemName: "radio.fill")
        return listTemplate
    }

    private func createMinSidaTemplate() -> CPTemplate {
        let item = CPListItem(text: "Profile 1", detailText: nil)
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Min sida", sections: [section])
        listTemplate.tabImage = UIImage(systemName: "person.fill")
        return listTemplate
    }
}
