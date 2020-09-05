defmodule Mgr.MixProject do
  use Mix.Project

  def project do
    [
      app: :mgr,
      version: "0.1.0",
      elixir: "~> 1.9",
      compilers: [:unifex, :bundlex] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:membrane_core, "~> 0.5.0"},
      {:membrane_element_ffmpeg_h264, "~> 0.2.0"},
      {:membrane_element_file, "~> 0.3.0"},
      {:membrane_element_sdl, "~> 0.3.0"},
      {:membrane_element_fake, "> 0.0.0"},
      {:membrane_rtp_plugin, "~> 0.4.0-alpha"},
      {:membrane_rtp_h264_plugin, "~> 0.3.0-alpha"},
      {:membrane_element_udp, "> 0.0.0"},
      {:unifex, github: "membraneframework/unifex", branch: "cpp_support", override: true},
      {:bundlex, github: "membraneframework/bundlex", branch: "cpp_support", override: true}
    ]
  end
end
