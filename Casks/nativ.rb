cask "nativ" do
  version "0.3.0"
  sha256 "5bd15ea7acd447d84dc2e727a32b57f3cda2046e61c49b2ab0c6088a24e3f0bb"

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
    "~/Library/HTTPStorages/io.github.blaizzy.nativ",
    "~/Library/HTTPStorages/io.github.blaizzy.nativ.binarycookies",
    "~/Library/Preferences/io.github.blaizzy.nativ.plist",
  ]
end
