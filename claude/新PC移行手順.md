# 新PC移行手順 (Claudeへの作業依頼用)

新PCにClaudeをインストールし、このリポジトリ(codeWork)をcloneした後、Claudeに「claude/新PC移行手順.md を読んで続きを進めて」と依頼するための手順書。
Claudeはこの文書を上から順に実行し、各ステップの結果を簡潔に報告すること。ログイン・パスワード・トークンの入力はユーザーが行う(Claudeは入力しない)。

## 前提情報

| 項目 | 旧PC(自宅) | 新PC(自宅) |
|------|-------------|--------------|
| ホスト名 | DESKTOP-VBKT10N | DESKTOP-9DFEGBP |
| ユーザー名 | hnk12 | owner |
| ユーザーフォルダ | C:\Users\hnk12 | C:\Users\owner |

- 会社PC: DESKTOP-JMG505U (今回の移行対象外)
- 作業フォルダは旧PCと同じ `D:\codeWork`、`D:\hnk\scripts` に置く(パス依存のため変更しない)。
- Googleドライブ(`G:\マイドライブ`)にバックアップがある: `G:\マイドライブ\PC移行バックアップ_20261010\`
  - `claude\projects\D--codeWork\memory\` と `claude\projects\D--hnk-scripts\memory\` : Claudeメモリ
  - `claude\skills\`、`claude\scheduled-tasks\`、`claude\settings.json`、`claude\CLAUDE.md`
  - `claude-mem-sync\pull.ps1`、`push.ps1` : claude-memのGit同期スクリプト(Git管理外)
  - `maya\` : `Documents\maya\scripts` と各種設定ファイル
- GitHubリポジトリ(アカウント hnk1219):
  - https://github.com/hnk1219/codework.git -> `D:\codeWork`
  - https://github.com/hnk1219/maya-scripts -> `D:\hnk\scripts`
  - https://github.com/hnk1219/claude-config.git -> `C:\Users\owner\.claude`
  - https://github.com/hnk1219/claude-mem-memory.git -> `C:\Users\owner\.claude-mem`

## 手順

### 1. 事前確認
1. `hostname` が `DESKTOP-9DFEGBP`、`$env:USERPROFILE` が `C:\Users\owner` であることを確認する。違えば作業を止めてユーザーに報告する。
2. `git --version`、`python --version`、`node --version`、`gh --version` の有無を確認し、未インストールのものを報告する(インストールはユーザーに依頼するか、wingetで提案して承認を得る)。
3. `G:\マイドライブ\PC移行バックアップ_20261010\` が見えるか確認する。見えなければGoogle Drive for Desktopの導入・同期完了をユーザーに依頼する。

### 2. リポジトリのclone (まだなら)
- `D:\codeWork` と `D:\hnk\scripts` をclone(または `git pull`)する。GitHub認証が必要ならユーザーに `gh auth login` を依頼する。
- 既にフォルダが存在する場合は上書きせず、`git status` で状態を確認して報告する。

### 3. .claude の復元 (claude-config)
1. `C:\Users\owner\.claude` が既に存在し中身がある場合は、削除せず内容を確認する。`.git` が無ければ以下の方法で取り込む:
   - 一時フォルダにcloneし、`.git` と追跡ファイルを `C:\Users\owner\.claude` にコピーする(既存の `.credentials.json` や `.claude.json` は触らない)。
2. `C:\Users\owner\.claude\generate-config.ps1` を実行し、`settings.template.json` と hooks のテンプレートから `__USERNAME__` を `owner` に置換した `settings.json` などを生成する。
   - 注意: テンプレートの `additionalDirectories` に `C:\Users\__USERNAME__\Documents\maya\scripts` 等が含まれる。生成後に `hnk12` が残っていないか `Grep` で確認する。
   - `block_bash_outside.ps1` と `log_access.ps1` はGit管理外の生成物なので、必ず生成されたことを確認する。
3. `hooks\session_title_icon.ps1` と `statusline.ps1` が新ホスト名 `DESKTOP-9DFEGBP` を自宅として判定することを確認する(対応済みのはず)。

### 4. メモリとスキルの復元
1. バックアップの `claude\projects\D--codeWork\memory\` を `C:\Users\owner\.claude\projects\D--codeWork\memory\` へコピーする。
2. 同様に `D--hnk-scripts\memory\` も戻す。
3. `claude\skills\` と `claude\scheduled-tasks\` を `C:\Users\owner\.claude\` 配下へコピーする。
4. コピー後、メモリ内に旧パス `C:\Users\hnk12` が残っていないか確認し、あれば `owner` に直す(内容の意味は変えない)。
5. 既存ファイルがある場合は上書き前に差分を確認して報告する。

### 5. claude-mem の復元
1. Claude Codeにログインした後(ユーザーが `/login` 実施)、プラグイン `claude-mem@thedotmack` をインストールする。
2. `C:\Users\owner\.claude-mem` に `claude-mem-memory` リポジトリをcloneし、`claude-mem.db` を取得する。
   - clone先が空でない場合(プラグインが先に初期化した場合)は、DBを上書きする前にユーザーに確認する。
3. バックアップの `claude-mem-sync\pull.ps1`、`push.ps1` を `C:\Users\owner\.claude-mem\sync\` へコピーする。
4. `settings.json` の SessionStart / SessionEnd hook がこのsyncスクリプトを指していること、パスが `owner` になっていることを確認する。
5. 補足: `claude-mem` の `.gitignore` は `claude-mem.db` のみ追跡する許可リスト方式。syncスクリプトは追跡されない。

### 6. Mayaスクリプト
- バックアップの `maya\scripts` を `C:\Users\owner\Documents\maya\scripts` へコピーする(Mayaのバージョン別フォルダ `2025` 等は新PCのMayaで作成されるので、必要なら `modelingToolsSettings`、`checkSheet` などの設定も戻す)。
- `D:\hnk\scripts\.claude\CLAUDE.md` の「D:\hnk\scriptsをスクリプトの正とする運用ルール」に従い、D:\hnk\scripts側を正としてMaya側へ反映する。
- Maya側の `userSetup.py` 等がD:\hnk\scriptsを参照している場合は、新PCでも動くことを確認する。

### 7. スケジュールタスクの再作成
`C:\Users\owner\.claude\scheduled-tasks\` の以下3件を、スケジュールタスク機能で再登録する。
- `daily-git-sync` (毎日 3時・4時 Git同期。SKILL.md内のパス `C:/Users/hnk12/.claude` を `C:/Users/owner/.claude` に直して登録)
- `compass-10th-anniversary-ticket` (2026-10-02 の発売リマインド。期日が過ぎていれば登録不要としてユーザーに確認)
- `minou-sabo-yakiimo-start` (2026-09-16 の催事リマインド。期日が過ぎていれば登録不要としてユーザーに確認)

### 7.5 Tablacus Explorer の復元
- `D:\codeWork\te260611` は `.gitignore` で除外されており、Gitにはない。cloneしても入らない。
- バックアップの `G:\マイドライブ\PC移行バックアップ_20261010\te260611\` を `D:\codeWork\te260611\` へコピーする(約3MB)。
  - `config\` に設定(menus.xml、key.xml、addons.xml、window.xml など)、`addons\` にアドオンが入っている。
  - 既に `D:\codeWork\te260611` が存在する場合は、上書き前にユーザーへ確認する。
- コピー後、`D:\codeWork\te260611\TE64.exe` を起動し、タブ・キー設定・アドオンが旧PC通りか確認してもらう。
- 旧PCで移行直前にTablacusを終了して `config\` を再コピーした場合は、そちらが最新。

### 8. MCP・拡張・その他
- Claude in Chrome拡張、MCPコネクタ(Google系など)は新PCで再接続が必要。ユーザーに案内する。
- `.claude.json` と `.credentials.json` は意図的にバックアップしていない。ログインで再生成される。

### 9. 動作確認 (最後に必ず実施)
1. `git -C D:\codeWork pull` / `git -C D:\hnk\scripts pull` / `git -C C:\Users\owner\.claude pull` が通る。
2. 新規セッションを開始し、CLAUDE.md・メモリが読み込まれ、セッションタイトルに自宅アイコンが付く。
3. claude-memのSessionStart hook (pull.ps1) がエラーなく動く。
4. `settings.json` に `hnk12` が残っていない (`Grep` で `hnk12` を検索)。
5. 問題が無ければ、結果を一覧で報告する。

## 旧PCに残る別資産 (Claudeが勝手にコピーしない)
- `D:\hnk\autosave` (1.6GB、Mayaオートセーブ)、`D:\hnk\CCSicon` (5.4MB)、`D:\hnk\line` (7.6MB)、`D:\hnk\room` (1.3MB)、`D:\hnk\x` (164KB) はGit管理外。必要なものは外付けドライブ等で別途移す。ユーザーの指示があれば手順を案内する。

## 注意
- 破壊的操作(強制push、reset、既存フォルダの削除・上書き)は、ユーザーの明示的な承認なしに行わない。
- パスワード・APIキー・トークンの入力はユーザーが行う。
- 旧PCの設定値(hnk12、DESKTOP-VBKT10N)が新PCで残っていたら、見つけ次第報告して修正を提案する。
