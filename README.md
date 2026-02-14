# 🐧 LinUtil: Modular Linux Utility Engine

Inspired by the transparency and power of Chris Titus Tech's WinUtil, **LinUtil** is a lightweight, bash-based framework designed to automate Linux system setup, maintenance, and optimization across multiple distributions.



## 🚀 Features
- **Cross-Distro Support:** Automatically detects `apt`, `dnf`, `pacman`, and `zypper`.
- **Plug-and-Play Architecture:** Drop a bash script into `/modules` and it's instantly integrated.
- **TUI Interface:** Clean, interactive menu powered by `whiptail`.
- **Self-Updating:** Pulls the latest core logic directly from GitHub.
- **Comprehensive Logging:** All actions are logged to `/tmp/linutil.log` for debugging.

## 🛠️ Installation & Usage
```bash
git clone [https://github.com/YOUR_USERNAME/linutil.git](https://github.com/YOUR_USERNAME/linutil.git)
cd linutil
chmod +x linutil.sh modules/*.sh
sudo ./linutil.sh

```

## 📂 Module Standard

Every module must handle three arguments to remain compatible with the core engine:

1. `name`: Returns the display name.
2. `desc`: Returns a short tooltip.
3. `run`: The execution logic.

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

```
Since we've got the code and the social presence ready, **would you like me to create a "Profiles" module?** This would allow you to select "Work", "Gaming", or "Privacy" and run a batch of modules at once!

```
