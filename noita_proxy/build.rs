fn main() {
    let repo = std::env::var("EW_GITHUB_REPO")
        .unwrap_or_else(|_| "IntQuant/noita_entangled_worlds".to_string());
    println!("cargo:rustc-env=EW_GITHUB_REPO={repo}");

    #[cfg(target_os = "linux")]
    println!("cargo:rustc-link-arg=-Wl,-rpath,$ORIGIN");

    if std::env::var("CARGO_CFG_TARGET_OS").unwrap() == "windows" {
        let mut res = winresource::WindowsResource::new();
        res.set_icon("assets/icon.ico");

        res.compile().unwrap();
    }
}
