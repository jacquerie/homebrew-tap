class Dwarfstar < Formula
  desc "Small native inference engine optimized first for DeepSeek V4 Flash"
  homepage "https://github.com/antirez/ds4"
  url "https://github.com/antirez/ds4/archive/84cc882352757baf628a1776badf7cc54d584e28.tar.gz"
  version "2026-08-13.1"
  sha256 "3ab2c4485bee87f36166b12ab59abbc293ad9fdfadb1c2920d1cbc7f617da165"
  license "MIT"

  depends_on :macos

  def install
    system "make"
    bin.install "ds4-server"
    bin.install "download_model.sh" => "ds4-download-model"

    # ds4-server reads the Metal kernel sources at runtime, looking for
    # metal/*.metal relative to its working directory. Ship them in the
    # Cellar so the service can find them; the service block below sets
    # its working directory here.
    (share/"dwarfstar"/"metal").install Dir["metal/*.metal"]

    # By default the upstream downloader drops GGUF weights next to the script
    # (which'd be Homebrew's bin/ directory). Reroute it to Homebrew's shared
    # etc/dwarfstar folder, and create the ds4flash.gguf symlink there too so
    # ds4-server can use it.
    inreplace bin/"ds4-download-model",
      'OUT_DIR=${DS4_GGUF_DIR:-"$ROOT/gguf"}',
      "OUT_DIR=${DS4_GGUF_DIR:-\"#{etc/"dwarfstar"}\"}"
    inreplace bin/"ds4-download-model",
      'ln -sfn "$OUT_DIR/$MODEL_FILE" ds4flash.gguf',
      'ln -sfn "$OUT_DIR/$MODEL_FILE" "$OUT_DIR/ds4flash.gguf"'
    inreplace bin/"ds4-download-model",
      'echo "Linked ./ds4flash.gguf -> $OUT_DIR/$MODEL_FILE"',
      'echo "Linked $OUT_DIR/ds4flash.gguf -> $OUT_DIR/$MODEL_FILE"'
    inreplace bin/"ds4-download-model",
      "Default: ./gguf",
      "Default: #{etc/"dwarfstar"}"
  end

  service do
    run [opt_bin/"ds4-server", "-m", etc/"dwarfstar"/"ds4flash.gguf"]
    # ds4-server needs the Metal kernel sources (metal/*.metal) relative to its
    # working directory, so run it from the directory that contains them.
    working_dir opt_pkgshare
    keep_alive true
    run_at_load true
    log_path var/"log/ds4-server.log"
    error_log_path var/"log/ds4-server.log"
  end

  def caveats
    <<~EOS
      A GGUF model must be downloaded before serving any requests. Download
      a model with the included helper, e.g. for a 96/128 GB Mac:

          #{bin}/ds4-download-model ds4f-q2

      Run `#{bin}/ds4-download-model` with no arguments to list all targets
      and their RAM requirements. Some targets need the Hugging Face CLI.

      Ignore the annotation below: currently only supports running as a
      Homebrew service because ds4-server looks for Metal kernels in a
      path relative to its working directory.
    EOS
  end
end
