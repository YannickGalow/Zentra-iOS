import SwiftUI

struct Links {
    static let instagramUsername = "yangalow05"
    static let youtubeUsername = "GVspeed187"

    static let instagramAppURL = URL(string: "instagram://user?username=\(instagramUsername)")!
    static let instagramWebURL = URL(string: "https://instagram.com/\(instagramUsername)")!

    static let youtubeAppURL = URL(string: "youtube://www.youtube.com/@\(youtubeUsername)")!
    static let youtubeWebURL = URL(string: "https://www.youtube.com/@\(youtubeUsername)")!

    static func openInstagram() {
        UIApplication.shared.open(instagramAppURL, options: [:]) { success in
            if !success {
                UIApplication.shared.open(instagramWebURL)
            }
        }
    }

    static func openYouTube() {
        UIApplication.shared.open(youtubeAppURL, options: [:]) { success in
            if !success {
                UIApplication.shared.open(youtubeWebURL)
            }
        }
    }
}
