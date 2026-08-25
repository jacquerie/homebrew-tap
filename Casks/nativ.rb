cask "nativ" do
  version "0.3.4"
  sha256 "deef96a7c3f0a69ed4d88f4fd00811aea139966d8ca13e7a6b4a8973eb6f5e9e"

  url "https://github.com/Blaizzy/nativ/releases/download/v#{version}/Nativ-#{version}.dmg"
  name "Nativ"
  desc "Run AI models locally"
  homepage "https://github.com/Blaizzy/nativ"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :tahoe

  app "Nativ.app"

  zap trash: [
    "~/Library/Application Support/Nativ",
    "~/Library/Caches/Nativ",
    "~/Library/Caches/io.github.blaizzy.nativ.plist",
    "~/Library/Preferences/io.github.blaizzy.nativ.plist",
  ]
end
