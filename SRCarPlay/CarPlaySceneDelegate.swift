//
//  CarPlaySceneDelegate.swift
//  SRCarPlay
//

import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    var newsEpisodes: [Episodes] = []

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        loadNews()
        setupInitialTemplate()
    }

    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    private func showEpisodeDetail(_ episode: Episodes) {
        let listItem = CPListItem(text: episode.title, detailText: episode.description)
        let section = CPListSection(items: [listItem])
        let detailTemplate = CPListTemplate(title: episode.title, sections: [section])
        interfaceController?.pushTemplate(detailTemplate, animated: true, completion: { _, _ in
            print("Episode detail template pushed")
        })
    }

    private func loadNews() {
        guard let url = URL(string: "https://api.sr.se/api/v2/news/episodes?format=json") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(News.self, from: data) {
                    DispatchQueue.main.async {
                        self.newsEpisodes = decodedResponse.episodes ?? [Episodes]()
                        self.setupInitialTemplate()
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
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
        let listItems = newsEpisodes.map { episode -> CPListItem in
            let listItem = CPListItem(text: episode.title, detailText: nil)
            listItem.handler = { [weak self] item, completion in
                self?.showEpisodeDetail(episode)
                completion()
            }
            return listItem
        }
        let section = CPListSection(items: listItems)
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
