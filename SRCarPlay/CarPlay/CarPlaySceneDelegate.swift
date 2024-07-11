//
//  CarPlaySceneDelegate.swift
//  SRCarPlay
//

import CarPlay
import MediaPlayer

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    private var player: AVPlayer?
    private var interfaceController: CPInterfaceController?
    private var newsEpisodes: [Episodes] = []
    private var channels: [Channel] = []
    
    private let secondsBackward: Double = 10
    private let secondsForward: Double = 10
    private var durationIsSet = false
    private var timeObserver: Any?
    private let placeholderImage = UIImage(systemName: "photo.circle.fill")
    private let basePath = "https://api.sr.se/api/v2"
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        loadNews()
        loadChannels()
        setupInitialTemplate()
    }
    
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
    private func loadNews() {
        guard let url = URL(string: basePath + "/news/episodes?format=json") else {
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
                    tmpEpisodes = tmpEpisodes.filter { $0.broadcast?.broadcastfiles?.first?.url != nil }
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

    private func loadChannels() {
        guard let url = URL(string: basePath + "/channels?format=json") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(ChannelsResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.channels = decodedResponse.channels
                        self.setupInitialTemplate()
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    private func setupInitialTemplate() {
        let nyheterTemplate = createNyheterTemplate()
        let kanalerTemplate = createKanalerTemplate()
        
        let tabBarTemplate = CPTabBarTemplate(templates: [nyheterTemplate, kanalerTemplate])
        
        interfaceController?.setRootTemplate(tabBarTemplate, animated: true, completion: { _, _ in
            print("Root template set")
        })
    }
    
    private func createNyheterTemplate() -> CPTemplate {
        let listItems = newsEpisodes.map { episode -> CPListItem in
            let listItem = CPListItem(text: episode.title ?? "", detailText: nil)
            listItem.setImage(placeholderImage)
            if let imageUrl = episode.imageurl, let url = URL(string: imageUrl) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data, let image = UIImage(data: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        listItem.setImage(image)
                    }
                }
                task.resume()
            }
            listItem.handler = { [weak self] item, completion in
                self?.showEpisodeDetail(episode)
                completion()
            }
            return listItem
        }
        let section = CPListSection(items: listItems)
        let listTemplate = CPListTemplate(title: "Nyheter", sections: [section])
        listTemplate.tabImage = UIImage(systemName: "doc.text.fill")
        return listTemplate
    }
    
    private func createKanalerTemplate() -> CPTemplate {
        let listItems = channels.map { channel -> CPListItem in
            let listItem = CPListItem(text: channel.name ?? "", detailText: channel.tagline ?? "")
            listItem.setImage(placeholderImage)
            if let imageUrl = channel.image, let url = URL(string: imageUrl) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data, let image = UIImage(data: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        listItem.setImage(image)
                    }
                }
                task.resume()
            }
            listItem.handler = { [weak self] item, completion in
                self?.showChannelDetail(channel)
                completion()
            }
            return listItem
        }
        let section = CPListSection(items: listItems)
        let listTemplate = CPListTemplate(title: "Kanaler", sections: [section])
        listTemplate.tabImage = UIImage(systemName: "radio.fill")
        return listTemplate
    }
    
    private func showEpisodeDetail(_ episodes: Episodes) {
        durationIsSet = false
        let urlString = episodes.broadcast?.broadcastfiles?.first?.url ?? episodes.url
        guard let urlString, let audioURL = URL(string: urlString) else {
            return
        }
        
        resetTimeObserver()
        // Create an AVPlayer instance with the audio URL
        player = AVPlayer(url: audioURL)
        
        setupNowPlayingInfoCenter()
        
        // Set the Now Playing Info
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episodes.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episodes.description // Use MPMediaItemPropertyArtist to set the description
        
        // Load the artwork image asynchronously
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: placeholderImage?.size ?? CGSize.zero) { _ in
            return self.placeholderImage ?? UIImage()
        }
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
        
        // Update the Now Playing Info when the player's current time changes
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] time in
            guard let self else { return }
            
            // This is to avoid that the time goes beyond the duration, and thus causing a jump in the timeline
            if let durationInSeconds = player?.currentItem?.duration.seconds {
                if !durationInSeconds.isNaN && time.seconds <= durationInSeconds {
                    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time.seconds
                }
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            if (!self.durationIsSet) {
                if (!(player?.currentItem?.duration.seconds.isNaN ?? true)) {
                    self.durationIsSet = true
                    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.duration.seconds
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        // Create a Now Playing Template
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        
        // Push the Now Playing Template to the interface controller
        interfaceController?.pushTemplate(nowPlayingTemplate, animated: true) { _, _ in }
        
        // Start playing the audio
        player?.play()
    }
    
    private func showChannelDetail(_ channel: Channel) {
        guard let liveAudioURLString = channel.liveaudio?.url, let liveAudioURL = URL(string: liveAudioURLString) else {
            return
        }
        
        resetTimeObserver()
        // Create an AVPlayer instance with the live audio URL
        player = AVPlayer(url: liveAudioURL)
        
        setupNowPlayingInfoCenter()
        
        // Set the Now Playing Info
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = channel.name ?? ""
        nowPlayingInfo[MPMediaItemPropertyArtist] = channel.tagline ?? ""
        
        // Load the artwork image asynchronously
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: placeholderImage?.size ?? CGSize.zero) { _ in
            return self.placeholderImage ?? UIImage()
        }
        if let imageUrl = channel.image, let artworkURL = URL(string: imageUrl) {
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
        interfaceController?.pushTemplate(nowPlayingTemplate, animated: true) { _, _ in }
        
        // Start playing the live audio
        player?.play()
    }
 
    private func setupNowPlayingInfoCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().playCommand.addTarget { event in
            self.player?.play()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { event in
            self.player?.pause()
            return .success
        }
        MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget { event in
            let cmTime = CMTime(seconds: (self.player?.currentTime().seconds ?? 0) - self.secondsBackward, preferredTimescale: 1)
            self.player?.seek(to: cmTime)
            return .success
        }
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget { event in
            let cmTime = CMTime(seconds: (self.player?.currentTime().seconds ?? 0) + self.secondsForward, preferredTimescale: 1)
            self.player?.seek(to: cmTime)
            return .success
        }
    }
    
    private func resetTimeObserver() {
        if let localTimeObserver = timeObserver {
            player?.removeTimeObserver(localTimeObserver)
            timeObserver = nil
        }
    }
    
}
