# Claude Desktop (Linux) でサインインできないとき

## 症状

ブラウザ側は

> Claudeアプリでサインインを完了する
> Claudeは自動的に開きます。開かない場合は、「Claudeを開く」を選択してください。

まで進むのに、「Claudeを開く」を押すと OS のダイアログが出て

> Open With… / **No Apps available**
> No apps installed that can open "…v1.895dc7ff-…"

となり、サインインが完了しない。

## 原因

サインインの最後は `claude://` という**カスタム URL スキーム**で認証コードを
デスクトップアプリに渡す設計になっている。上のダイアログは
「`claude://` を開けるアプリが OS に登録されていない」という意味で、
原因は次のどちらか。

### 1. Claude Desktop 自体が入っていない

Claude Desktop の公式ビルドは macOS / Windows のみ。Linux では
コミュニティビルド（AUR の `claude-desktop-bin` など）を入れていない限り
`claude://` を受け取るアプリが存在しない。

→ ブラウザで claude.ai を使うか、ターミナルなら Claude Code CLI を使う。
   デスクトップアプリが必要ならコミュニティビルドを入れる。

### 2. 入っているが、アプリが自作した .desktop が壊れている

Claude Desktop は起動のたびに

```
~/.local/share/applications/com.anthropic.Claude.desktop
```

を自動生成する（末尾に `X-Claude-Generated=true` が付く）。このファイルは

- `/usr/share/applications/com.anthropic.Claude.desktop`（パッケージ同梱の
  正しいエントリ）を**同名でシャドウ**し、
- GIO のアプリ**列挙**からは漏れる

という状態になる。結果、既定ハンドラとしては解決されるのに一覧には出ない、
という中途半端な状態になり、ブラウザは「開けるアプリが無い」と表示する。

確認コマンド：

```bash
gio mime x-scheme-handler/claude
```

壊れているときの出力：

```
Default application for "x-scheme-handler/claude": com.anthropic.Claude.desktop
No registered applications
No registered applications
```

（既定は解決するのに registered が空、というのが目印）

## 直し方

### スクリプトを使う

```bash
fix-claude-url-handler          # 診断して修復
fix-claude-url-handler --check  # 診断のみ
fix-claude-url-handler --test   # claude:// を実際に開いて確認
fix-claude-url-handler --undo   # 取り消し
```

やっていることは下の手動手順と同じ。

### 手動でやる

アプリが触らない**別名**の .desktop を用意して、そちらを既定にするのがポイント。
`com.anthropic.Claude.desktop` を直しても、アプリ起動時に上書きされて再発する。

```bash
# 1. 壊れた自動生成エントリを退避（同名シャドウを解消）
mv ~/.local/share/applications/com.anthropic.Claude.desktop{,.bak}

# 2. 別名のハンドラを作る
cat > ~/.local/share/applications/claude-url-handler.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Claude (claude:// link handler)
Comment=Handles claude:// deep links such as the sign-in handoff
Exec=claude-desktop %u
Icon=claude-desktop
Terminal=false
StartupNotify=true
StartupWMClass=com.anthropic.Claude
MimeType=x-scheme-handler/claude;
EOF

# 3. データベース更新と既定の設定
update-desktop-database ~/.local/share/applications
xdg-mime default claude-url-handler.desktop x-scheme-handler/claude

# 4. 確認
xdg-mime query default x-scheme-handler/claude   # -> claude-url-handler.desktop
gio mime x-scheme-handler/claude                 # registered に出ること
xdg-open 'claude://claude.ai/new'                # アプリが前面に出れば成功
```

必要なパッケージ：

```bash
sudo pacman -S xdg-utils desktop-file-utils
```

> `NoDisplay=true` は付けない。付けるとランチャーからは消えるが、ブラウザが出す
> 「アプリで開く」ダイアログ（GtkAppChooser / xdg-desktop-portal）の一覧からも
> 消えるため、症状が再発しうる。

## それでも直らないとき

- **ブラウザを再起動する。** ハンドラの一覧は起動時にキャッシュされることがある。
- **ブラウザが Flatpak / Snap 版**だと、サンドボックス内からホストの .desktop が
  見えず一覧が空になる。`xdg-desktop-portal`（+ WM に合ったバックエンド。
  Hyprland なら `xdg-desktop-portal-hyprland` と `xdg-desktop-portal-gtk`）を
  入れておく。それでも駄目ならネイティブパッケージのブラウザで試す。
- **Firefox** の場合、`about:config` の
  `network.protocol-handler.expose.claude` を `false` にすると外部アプリへ
  渡す挙動になる。`about:preferences` の「プログラム」欄で claude を
  Claude に割り当ててもよい。
- **先に Claude Desktop を起動しておく。** 起動済みだと受け渡しが安定する。
- どうしても通らなければ、ブラウザ版 claude.ai か Claude Code CLI を使う。

## 参考

- [anthropics/claude-code#93688 — Desktop app's self-generated .desktop entry breaks its own claude:// login handoff](https://github.com/anthropics/claude-code/issues/93688)
- [anthropics/claude-code#94884 — Linux: login dead-ends at "Finish sign-in in the Claude app"](https://github.com/anthropics/claude-code/issues/94884)
- [AUR: claude-desktop-bin](https://aur.archlinux.org/packages/claude-desktop-bin)
- [Arch Wiki: Default applications](https://wiki.archlinux.org/title/XDG_MIME_Applications)
