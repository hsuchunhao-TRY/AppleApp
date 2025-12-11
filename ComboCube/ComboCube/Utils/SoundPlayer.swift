import Foundation
import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()
    private var player: AVAudioPlayer?

    private init() {}

    /// 播放 Resources 資料夾內音效
    /// 支援 WAV（可改成 mp3、m4a，只要放在 Resources）
    func play(_ name: String, type: String = "wav") {
        guard let url = Bundle.main.url(forResource: name, withExtension: type) else {
            print("🔊 SoundPlay: 找不到音效檔 \(name).\(type)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("🔊 SoundPlay: 播放失敗 - \(error.localizedDescription)")
        }
    }

    /// 停止播放
    func stop() {
        player?.stop()
        player = nil
    }
}
