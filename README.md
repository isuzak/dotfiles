# keyd 完全説明書（Ultimate Edition）

## 目次

1. keyd とは  
2. インストール  
3. 設定ファイルの場所  
4. `[ids]` の役割（とても重要）  
5. 基本構造（main / layer / overload）  
6. 最終版 default.conf（あなた専用）  
7. Capslayer おすすめパックの意図  
8. デバッグ方法  
9. Stow による管理方法  
10. 外付けキーボード対応  
11. トラブルシューティング  
12. まとめ  

---

# 1. keyd とは

**keyd は Linux 用の高速・低レイヤーのキーボードリマッパーです。**

- Wayland / X11 / TTY すべてで動作  
- デュアルロール（tap/hold）  
- レイヤー  
- 矢印・単語移動・選択などのカスタム  
- Vim 操作・Mac 操作体系の統合  
- Hyprland との相性がとても良い  

---

# 2. インストール

```bash
sudo pacman -S keyd
sudo systemctl enable --now keyd
```

---

# 3. 設定ファイルの場所

keyd が読み込むのは：

```
/etc/keyd/default.conf
```

Stow 管理する場合の構成：

```
~/dotfiles/keyd/etc/keyd/default.conf
```

---

# 4. `[ids]` の役割（最重要ポイント）

どのキーボードに設定を適用するかを指定します。

例：

```ini
[ids]
0001:0001
```

調べ方：

```
sudo keyd monitor
```

ログに出る：

```
device added: 0001:0001:xxxxxx AT Translated Set 2 keyboard
```

の先頭2つ（0001:0001）を使用します。

複数キーボード可：

```ini
[ids]
0001:0001
046d:c31c
abcd:1234
```

---

# 5. 設定ファイルの基本構造

```ini
[ids]
（適用対象キーボードID）

[main]
（通常時キーバインド）

[layername]
（レイヤー定義）
```

---

## デュアルロール（overload）

```
overload(レイヤー名, タップ時の動作)
```

例：

```ini
space = overload(shift, space)
capslock = overload(capslayer, esc)
```

---

# 6. 最終版 default.conf（あなた専用カスタム）

```ini
[ids]
0001:0001

[main]
# Alt と Ctrl 入れ替え
leftalt  = leftctrl
leftctrl = leftalt

# Space デュアルロール（tap: space / hold: shift）
space = overload(shift, space)

# Caps デュアルロール（tap: esc / hold: capslayer）
capslock = overload(capslayer, esc)

###########################################
# Caps Layer（Caps 押しながら有効）
###########################################
[capslayer]
# Vim カーソル移動
h = left
j = down
k = up
l = right

# 編集
semicolon = backspace
d = delete
m = enter

# 全選択
a = C-a

# 行頭・行末
u = home
o = end

# ページ移動
i = pageup
p = pagedown

# 単語移動
b = C-left
f = C-right

# Shift + 矢印（選択）
H = S-left
J = S-down
K = S-up
L = S-right

# クリップボード
c = C-c
x = C-x
v = C-v
z = C-z
y = C-y

# タブ操作・リロード
n = C-tab
N = C-S-tab
w = C-w
r = C-r

# 戻る・進む
comma  = alt-left
period = alt-right
```

---

# 7. Capslayer おすすめパックの意図

| キー         | 動作                     | 理由                     |
| ------------ | ------------------------ | ------------------------ |
| h/j/k/l      | ←↓↑→                     | Vim による手の位置最適化 |
| u/o          | Home / End               | 行移動が高速             |
| i/p          | PageUp / Down            | 大移動                   |
| b/f          | 単語移動                 | テキスト編集が速い       |
| H/J/K/L      | Shift+矢印               | 選択操作が快適           |
| c/x/v        | コピー/切り取り/貼り付け | OS 全域で統一            |
| m            | Enter                    | ホームポジションから改行 |
| semicolon    | Backspace                | 右手で押しやすい         |
| comma/period | 戻る/進む                | ブラウザ作業向上         |

---

# 8. デバッグ方法

## イベント監視（最強）

```bash
sudo keyd monitor
```

## サービス状態

```bash
systemctl status keyd
```

## 再起動

```bash
sudo systemctl restart keyd
```

---

# 9. Stow による管理方法（推奨）

dotfiles 構造：

```
~/dotfiles/
└── keyd/
    └── etc/
        └── keyd/
            └── default.conf
```

Stow 実行：

```bash
cd ~/dotfiles
stow -t / keyd
```

結果：

```
/etc/keyd/default.conf → ~/dotfiles/keyd/etc/keyd/default.conf
```

---

# 10. 外付けキーボード対応

1. 接続して：

```
sudo keyd monitor
```

2. `device added:` の ID を取得  

3. それを `[ids]` に追加：

```ini
[ids]
0001:0001
abcd:1234
```

4. 再起動：

```
sudo systemctl restart keyd
```

---

# 11. トラブルシューティング

| 症状                           | 原因                     | 対処                          |
| ------------------------------ | ------------------------ | ----------------------------- |
| Caps が Esc にならない         | Hyprland との remap 衝突 | kb_options を無効化           |
| Space デュアルロールが効かない | overload の syntax ミス  | 正しい構文を確認              |
| 外付けキーボードだけ無効       | ids が足りない           | `[ids]` に追加                |
| 設定反映されない               | systemd の再起動忘れ     | `sudo systemctl restart keyd` |

---

# 12. まとめ

- keyd は Linux/Wayland で最強のキーボードリマップツール  
- デュアルロール + レイヤーで操作性が劇的に向上  
- Caps レイヤーはホームポジション維持に最適  
- Stow と併用することで再現性の高い環境構築が可能  
- `[ids]` を正しく管理すれば複数キーボードも簡単に対応可能  

---
