cask "nativ" do
  version "0.3.1"
  sha256 "225002b9bca817b1acb8ccf3fc947923eb5c4768d6dbc6c35383c1c2f8d07843"

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
