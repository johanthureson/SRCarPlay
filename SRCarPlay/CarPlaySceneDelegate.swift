//
//  CarPlaySceneDelegate.swift
//  SRCarPlay
//

import CarPlay
import AVFoundation
import MediaPlayer

// Add a player property to your class
var player: AVPlayer?

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    var newsEpisodes: [Episodes] = []
    
    private let secondsBackward: Double = 10
    private let secondsForward: Double = 10
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        loadNews()
        setupInitialTemplate()
    }
    
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
    private func showEpisodeDetail(_ episodes: Episodes) {
        let urlString = episodes.broadcast?.broadcastfiles?.first?.url ?? episodes.url
        guard let urlString, let audioURL = URL(string: urlString) else {
            return
        }
        
        // Create an AVPlayer instance with the audio URL
        player = AVPlayer(url: audioURL)
        
        setupNowPlayingInfoCenter()
        
        // Set the Now Playing Info
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episodes.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episodes.description // Use MPMediaItemPropertyArtist to set the description
        
        // Load the artwork image asynchronously
        if let imageUrl = episodes.imageurl, let artworkURL = URL(string: imageUrl) {
            let task = URLSession.shared.dataTask(with: artworkURL) { (data, response, error) in
                guard let data = data, let artworkImage = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in artworkImage }
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
            task.resume()
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        // Create a Now Playing Template
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        
        // Push the Now Playing Template to the interface controller
        interfaceController?.pushTemplate(nowPlayingTemplate, animated: true) { _, _ in
        }
        
        // Start playing the audio
        player?.play()
    }
    
    func setupNowPlayingInfoCenter(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().playCommand.addTarget { event in
            player?.play()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { event in
            player?.pause()
            return .success
        }
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget { event in
            let cmTime = CMTime(seconds: (player?.currentTime().seconds ?? 0) + self.secondsForward, preferredTimescale: 1)
            player?.seek(to: cmTime)
            return .success
        }
        MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget { event in
            let cmTime = CMTime(seconds: (player?.currentTime().seconds ?? 0) - self.secondsBackward, preferredTimescale: 1)
            player?.seek(to: cmTime)
            return .success
        }
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
                    var tmpEpisodes = decodedResponse.episodes ?? [Episodes]()
                    // Filter out episodes where audiopreference is equal to "pod"
                    tmpEpisodes = tmpEpisodes.filter { $0.audiopreference != "pod" }
                    DispatchQueue.main.async {
                        self.newsEpisodes = tmpEpisodes
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
