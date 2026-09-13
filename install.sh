#!/usr/bin/env bash
# =============================================================================
# install.sh —— 用户级依赖安装 / 升级脚本
# =============================================================================
# 这个脚本安装 ~/.config/nvim 这套配置需要的「外部程序」：
#   Neovim、ripgrep、fd、xclip、lazygit、ImageMagick(+rsvg)、
#   LSP 服务（TS/React、Vue、C#、HTML/CSS/JSON/ESLint/Tailwind/Emmet）、
#   格式化器（stylua/black/isort/prettier/shfmt）
#
# 特点：
#   * 全部装到 ~/.local 与 ~/.npm-global，**不需要 sudo**，不碰系统目录
#   * 幂等：已经装好的会跳过；加 --upgrade 可强制更新到最新版
#   * 升级途径：`./install.sh --upgrade`（插件升级见 README 的 lazy.nvim 部分）
#
# 用法：
#   ./install.sh              只补缺失的
#   ./install.sh --upgrade    额外把已有程序更新到最新版
#
# 前提：Debian / Ubuntu / Mint，且已装 curl、git、node/npm；C# 需要 dotnet SDK
# =============================================================================
set -euo pipefail

BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
NPM_GLOBAL="$(npm prefix -g 2>/dev/null || echo "$HOME/.npm-global")"
UPGRADE=0
[[ "${1:-}" == "--upgrade" ]] && UPGRADE=1

mkdir -p "$BIN" "$OPT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '\033[1;32m[跳过]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[注意]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[错误]\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }
# 已经装好且不是 --upgrade 模式 → 跳过
skip_if_installed() { [[ $UPGRADE -eq 0 ]] && have "$1"; }

api_tag() { # owner/repo -> 最新 release tag
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1
}

[[ "$(uname -m)" == "x86_64" ]] || die "本脚本只适配 x86_64，当前是 $(uname -m)"

# ─────────────────────────────────────────────────────────────────────────────
# 1. Neovim
# ─────────────────────────────────────────────────────────────────────────────
if [[ $UPGRADE -eq 0 && -x "$OPT/nvim-linux-x86_64/bin/nvim" ]]; then
  skip "nvim  $("$OPT/nvim-linux-x86_64/bin/nvim" --version | head -1)"
else
  info "安装/更新 Neovim (stable)"
  curl -fSL -o "$TMP/nvim.tar.gz" \
    https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
  rm -rf "$OPT/nvim-linux-x86_64"
  tar -xzf "$TMP/nvim.tar.gz" -C "$OPT"
  ln -sfn "$OPT/nvim-linux-x86_64/bin/nvim" "$BIN/nvim"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 2. GitHub Release 里的单个二进制
#    github_bin <命令名> <owner/repo> <asset 模板> <包内路径>
#    模板占位符：{tag} = 原始 tag（v0.65.0），{vtag} = 去掉 v（0.65.0）
# ─────────────────────────────────────────────────────────────────────────────
github_bin() {
  local cmd="$1" repo="$2" asset_tpl="$3" inner="$4" tag asset
  if skip_if_installed "$cmd"; then skip "$cmd"; return 0; fi
  tag="$(api_tag "$repo")"
  [[ -n "$tag" ]] || { warn "$cmd: 取不到 release tag（网络？），跳过"; return 0; }
  asset="${asset_tpl//\{tag\}/$tag}"
  asset="${asset//\{vtag\}/${tag#v}}"
  info "安装 $cmd ($tag)"
  if ! curl -fSL "https://github.com/$repo/releases/download/$tag/$asset" -o "$TMP/pkg"; then
    warn "$cmd: 下载失败，跳过"; return 0
  fi
  rm -rf "$TMP/x" && mkdir -p "$TMP/x"
  case "$asset" in
    *.zip) unzip -oq "$TMP/pkg" -d "$TMP/x" ;;
    *)     tar -xzf "$TMP/pkg" -C "$TMP/x" ;;
  esac
  install -m 755 "$TMP/x/$inner" "$BIN/$cmd"
}

github_bin rg      BurntSushi/ripgrep    "ripgrep-{tag}-x86_64-unknown-linux-musl.tar.gz" rg
github_bin fd      sharkdp/fd            "fd-{tag}-x86_64-unknown-linux-gnu.tar.gz"      fd
github_bin lazygit jesseduffield/lazygit "lazygit_{vtag}_linux_x86_64.tar.gz"             lazygit
github_bin shfmt   mvdan/sh              "shfmt_{tag}_linux_amd64"                        shfmt
github_bin stylua  JohnnyMorganz/StyLua  "stylua-linux-x86_64.zip"                        stylua

# ─────────────────────────────────────────────────────────────────────────────
# 3. LSP 服务（npm 全局）
# ─────────────────────────────────────────────────────────────────────────────
have npm || die "找不到 npm，请先安装 Node.js"
info "安装/更新 LSP 服务 (npm 全局)"
npm install -g --silent \
  typescript \
  typescript-language-server \
  @vtsls/language-server \
  @vue/language-server \
  @vue/typescript-plugin \
  vscode-langservers-extracted \
  @tailwindcss/language-server \
  @olrtg/emmet-language-server

# Vue 语言服务（Volar）需要一个带 `ts.server` API 的 TypeScript 5。
# 现在 npm 上 `typescript` 最新版已是 7.x（原生版，只有 tsc CLI、没有库 API），
# 所以往这两个包内部塞一份 TypeScript 5，与全局版本隔离。
# 注意：升级 @vue/language-server 后 npm 会清掉它，重跑本脚本即可修复。
need_ts5() { # <包目录名>
  local d="$NPM_GLOBAL/lib/node_modules/$1"
  [[ -d "$d" ]] || return 0
  [[ -f "$d/node_modules/typescript/lib/tsserverlibrary.js" ]] && return 0
  info "为 $1 内置 TypeScript 5"
  rm -f "$TMP"/typescript-5*.tgz
  npm pack typescript@5 --pack-destination "$TMP" >/dev/null 2>&1
  mkdir -p "$d/node_modules"
  rm -rf "$d/node_modules/typescript"
  tar -xzf "$TMP"/typescript-5*.tgz -C "$d/node_modules"
  mv "$d/node_modules/package" "$d/node_modules/typescript"
}
need_ts5 @vue/language-server
need_ts5 typescript-language-server

# ─────────────────────────────────────────────────────────────────────────────
# 4. C# 语言服务 OmniSharp（需要系统已装 dotnet SDK）
# ─────────────────────────────────────────────────────────────────────────────
if ! have dotnet; then
  warn "没装 dotnet SDK，C# 语言服务无法工作：https://dotnet.microsoft.com/download"
elif skip_if_installed OmniSharp; then
  skip "OmniSharp"
else
  OM_TAG="$(api_tag OmniSharp/omnisharp-roslyn)"
  info "安装 OmniSharp ($OM_TAG)"
  curl -fSL -o "$TMP/omni.tar.gz" \
    "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/$OM_TAG/omnisharp-linux-x64-net6.0.tar.gz"
  rm -rf "$OPT/omnisharp" && mkdir -p "$OPT/omnisharp"
  tar -xzf "$TMP/omni.tar.gz" -C "$OPT/omnisharp"
  cat > "$BIN/OmniSharp" <<'WRAP'
#!/bin/sh
exec "$HOME/.local/opt/omnisharp/OmniSharp" "$@"
WRAP
  chmod 755 "$BIN/OmniSharp"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 4.5 Rust 语言服务 rust-analyzer
#     注意：~/.cargo/bin/rust-analyzer 只是 rustup 的代理壳，如果当前 toolchain
#     没装 rust-analyzer 组件，它执行时会报 "Unknown binary"，Rust 的补全/提示
#     会全部失效。所以这里必须真的能跑起来才算装好。
# ─────────────────────────────────────────────────────────────────────────────
if ! have rustup; then
  warn "没有 rustup，跳过 rust-analyzer（https://rustup.rs）"
elif rust-analyzer --version >/dev/null 2>&1 && [[ $UPGRADE -eq 0 ]]; then
  skip "rust-analyzer  $(rust-analyzer --version 2>/dev/null | head -1)"
else
  info "安装/更新 rust-analyzer (rustup component)"
  rustup component add rust-analyzer
fi

# ─────────────────────────────────────────────────────────────────────────────
# 5. Debian/Ubuntu 专有：xclip + ImageMagick 6
#    用 `apt-get download` 取官方 deb 再解包到 ~/.local，全程不需要 root
# ─────────────────────────────────────────────────────────────────────────────
if have apt-get && have dpkg; then
  if skip_if_installed xclip; then
    skip "xclip"
  else
    info "安装 xclip（Neovim 的 clipboard=unnamedplus 需要它）"
    if ( cd "$TMP" && apt-get download xclip >/dev/null 2>&1 ); then
      dpkg -x "$TMP"/xclip_*.deb "$TMP/xclip"
      install -m 755 "$TMP/xclip/usr/bin/xclip" "$BIN/xclip"
    else
      warn "xclip 下载失败，跳过（剪贴板暂时不可用）"
    fi
  fi

  if skip_if_installed magick; then
    skip "magick"
  else
    info "安装 ImageMagick 6 + rsvg-convert（real-icons.nvim 需要 magick）"
    apt_pkg() { # 兼容 64 位 time_t 过渡后的 t64 包名
      local c
      for c in "$1" "$1"t64; do
        if apt-cache show "$c" >/dev/null 2>&1; then echo "$c"; return 0; fi
      done
      echo "$1"
    }
    if ( cd "$TMP" && apt-get download \
          "$(apt_pkg imagemagick-6.q16)" \
          "$(apt_pkg libmagickcore-6.q16-7)" \
          "$(apt_pkg libmagickwand-6.q16-7)" \
          libfftw3-double3 imagemagick-6-common librsvg2-bin >/dev/null 2>&1 ); then
      rm -rf "$OPT/imagemagick6" && mkdir -p "$OPT/imagemagick6"
      for d in "$TMP"/*.deb; do dpkg -x "$d" "$OPT/imagemagick6"; done
      install -m 755 "$OPT/imagemagick6/usr/bin/rsvg-convert" "$BIN/rsvg-convert"
      cat > "$BIN/magick" <<'WRAP'
#!/bin/sh
# 用户级 ImageMagick 6 封装成 `magick`（real-icons.nvim 硬性要求），详见仓库 README
IM6="$HOME/.local/opt/imagemagick6"
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH
MODDIR=$(ls -d "$IM6"/usr/lib/*/ImageMagick-*/modules-Q16 2>/dev/null | head -1)
export MAGICK_HOME="$IM6/usr"
export MAGICK_CONFIGURE_PATH="$IM6/etc/ImageMagick-6"
[ -n "$MODDIR" ] && export MAGICK_CODER_MODULE_PATH="$MODDIR/coders"
[ -n "$MODDIR" ] && export MAGICK_FILTER_MODULE_PATH="$MODDIR/filters"
export LD_LIBRARY_PATH="$IM6/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$IM6/usr/bin/convert-im6.q16" "$@"
WRAP
      chmod 755 "$BIN/magick"
    else
      warn "ImageMagick 相关 deb 下载失败，跳过（图标会退化成字形）"
    fi
  fi
else
  warn "没有 apt-get/dpkg：跳过 xclip 与 ImageMagick（请自行安装 xclip 与 ImageMagick 7 的 magick）"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 6. 格式化器（conform.nvim 用）
# ─────────────────────────────────────────────────────────────────────────────
if have pipx; then
  info "安装/更新 black + isort"
  pipx install black >/dev/null 2>&1 || pipx upgrade black >/dev/null 2>&1 || true
  pipx install isort >/dev/null 2>&1 || pipx upgrade isort >/dev/null 2>&1 || true
else
  warn "没有 pipx：跳过 black/isort（可 python3 -m pip install --user pipx && pipx ensurepath）"
fi

info "安装/更新 prettier"
npm install -g --silent prettier

# ─────────────────────────────────────────────────────────────────────────────
# 7. 结果检查
# ─────────────────────────────────────────────────────────────────────────────
echo
info "检查结果："
MISSING=0
for c in nvim rg fd xclip lazygit magick rsvg-convert stylua black isort prettier shfmt \
         vtsls vue-language-server typescript-language-server OmniSharp \
         vscode-html-language-server vscode-css-language-server vscode-json-language-server \
         vscode-eslint-language-server tailwindcss-language-server emmet-language-server; do
  if have "$c"; then printf '  \033[1;32m✓\033[0m %s\n' "$c"
  else printf '  \033[1;31m✗\033[0m %s\n' "$c"; MISSING=1; fi
done

# rust-analyzer 必须真的能执行：只判断文件存在会被 rustup 代理壳骗过
if have rust-analyzer; then
  if rust-analyzer --version >/dev/null 2>&1; then
    printf '  \033[1;32m✓\033[0m rust-analyzer (%s)\n' "$(rust-analyzer --version 2>/dev/null | head -1)"
  else
    printf '  \033[1;31m✗\033[0m rust-analyzer 组件缺失 —— 执行: rustup component add rust-analyzer\n'
    MISSING=1
  fi
fi

echo
if [[ $MISSING -eq 1 ]]; then
  warn "有程序没装上，往上翻看报错；修好后重跑本脚本即可（幂等）。"
else
  info "全部就绪，直接运行 nvim 即可。"
fi
