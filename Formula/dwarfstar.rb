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
    bin.install "ds4", "ds4-server", "ds4-bench", "ds4-eval", "ds4-agent"
    bin.install "download_model.sh" => "ds4-download-model"

    # ds4-server reads the Metal kernel sources at runtime, looking for
    # metal/*.metal relative to its working directory (the paths are not
    # embedded into the binary). Ship them in the Cellar so the service can
    # find them; the service block below sets its working directory here.
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
      A GGUF model must be downloaded before ds4-server can serve any requests.
      Models are large (tens to hundreds of GB) and depend on your hardware, so
      this is left for you to do rather than run automatically at install time.

      Download a model with the included helper, e.g. for a 96/128 GB Mac:

          #{bin}/ds4-download-model ds4f-q2

      Run `#{bin}/ds4-download-model` with no arguments to list all targets
      and their RAM requirements. Some targets need the Hugging Face CLI.

      Downloaded models are installed in Homebrew's etc/dwarfstar directory:

          #{etc/"dwarfstar"}/

      A `ds4flash.gguf` symlink pointing at the latest downloaded model is
      created there, and the background service (started with
      `brew services start jacquerie/tap/dwarfstar`) loads it automatically:

          #{etc/"dwarfstar"}/ds4flash.gguf

      To serve a specific downloaded file manually, point the server at it:

          #{opt_bin}/ds4-server -m /path/to/model.gguf

      ds4-server reads its Metal kernel sources (metal/*.metal) at runtime
      relative to the directory it is launched from. The background service
      handles this automatically by running from:

          #{share}/dwarfstar/

      For manual runs, either cd into that directory first or set the
      DS4_METAL_*_SOURCE environment variables (e.g.
      DS4_METAL_FLASH_ATTN_SOURCE) to the installed .metal files:

          #{share}/dwarfstar/metal/

      The download directory can be overridden with the DS4_GGUF_DIR
      environment variable.

      See https://github.com/antirez/ds4 for full usage.
    EOS
  end
end
