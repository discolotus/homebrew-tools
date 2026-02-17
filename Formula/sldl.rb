class Sldl < Formula
  desc "Advanced downloader for Soulseek"
  homepage "https://github.com/fiso64/slsk-batchdl"
  version "2.6.0"

  on_macos do
    on_arm do
      url "https://github.com/fiso64/slsk-batchdl/releases/download/v2.6.0/sldl_osx-arm64.zip"
      sha256 "d1029e2dbdd69c826f8a26429fe01116f39d0e4da8690ca992657bc22916d05e"
    end

    on_intel do
      url "https://github.com/fiso64/slsk-batchdl/releases/download/v2.6.0/sldl_osx-x64.zip"
      sha256 "1d36f4bb6749d3169a90150ea9817d0d7db2ed48b9b33716bc304700baa087bd"
    end
  end

  def install
    chmod 0o755, "sldl"
    bin.install "sldl"
  end

  test do
    assert_match "2.6.0", shell_output("#{bin}/sldl --version 2>&1")
  end
end
