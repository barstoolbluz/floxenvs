# 🐍 A Python Dev Environment That Just Works Everywhere

This Flox environment gives you Python 3.13 with better venv management and sane defaults. It's built for developers who want to skip the venv headaches and get to work.

## ✨ What You Get

- Painless virtual environment management
- Smart project initialization
- Dependency management that just works
- One-liner commands for common workflows
- Shell completion built in for bash, zsh, and fish
- No more fighting with your Python tooling

## 🧰 Tools Included

- `python3.13` - Latest stable Python 3.13 release
- `pip` - Package manager that doesn't get in your way
- `gum` - TUI components for smooth workflows
- `zlib` - Required dependency for many packages

## 🚀 Getting Started

### Prerequisites

- [Flox](https://flox.dev/get) installed
- Basic Python knowledge

### Setup

```sh
git clone https://github.com/youruser/python-env && cd python-env
flox activate
```

## 📝 Common Workflows

### Environment Management

```bash
# Create a new virtual environment in current directory
mkvenv

# Find and activate any venv in current directory tree
aktivate

# Safely exit current virtual environment
qwit

# Create a fully-configured new project
mkprojekt
```

### Package Management

```bash
# Install from requirements.txt with auto venv handling
pist

# Save currently installed packages to requirements.txt
freezereqs

# Check for outdated packages and update them
chkupdates
```

### Development

```bash
# Run code quality checks (black, flake8, isort)
lint

# Smart-execute any Python file (or auto-find main.py)
run [file.py]
```

## 🔧 Features That Matter

### `mkprojekt` - Project Bootstrapping Done Right

This command:
1. Creates a new directory with your project name
2. Sets up a Python venv
3. Asks which packages you need
4. Creates a starter .gitignore
5. Initializes git
6. Gets you ready to code in seconds

### Smart Virtual Environment Handling

All commands automatically find or create venvs as needed:
- `aktivate` scans for any venv in your project tree
- `pist` ensures a venv exists before installing packages
- `run` activates a venv before executing your code

### Multi-shell Support

Works the same way in:
- Bash
- Zsh
- Fish

## 🔥 Troubleshooting

Having issues? Try these:

1. **Virtual environment not activating**:
   - Check that you have permissions for the directory
   - Try `rm -rf .venv` and create it again with `mkvenv`

2. **Package installation fails**:
   - Try `pip install --upgrade pip` in your venv
   - Check that required system libraries are available

3. **Linting errors**:
   - Use `lint --fix` to automatically fix common issues
   - Customize with `.flake8` or `pyproject.toml` in your project

## 💻 System Support

Runs on:
- macOS (ARM/Intel)
- Linux (ARM/x86)

## 🔍 Power User Tips

- Use `mkprojekt` with `fastapi` or `django` for quick API/web projects
- The `run` command auto-detects common entry points like `main.py`, `app.py`, and `manage.py`
- Add your commonly used packages to the `mkprojekt` selection menu by editing the manifest

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
