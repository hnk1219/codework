# Mayaツール群 引き継ぎノート

作業環境: Maya 2024.2.5 / Python 3 / Windows 11
本番スクリプト置き場: D:\hnk\script

このドキュメントは、これまでの開発経緯・設計判断・既知の問題を新しい作業環境（Claude Code）に引き継ぐためのものです。各スクリプトを修正する際は、ここに書かれた過去の経緯を踏まえてください。

---

## customShelf.py（カスタムフローティングシェルフ）

用途: ドラッグで並び替え可能なカスタムMayaシェルフ。

設計方針・経緯:
- サイズは自由ドラッグリサイズをやめ、3段階の固定プリセット（narrow/medium/wide）方式に変更済み。ウィンドウ幅・高さはQtのライブ計測ではなく、列数・ボタン数から算術的に計算している。
- リサイズ順序は「拡大 → レイアウト再ラップ → 縮小」の3ステップが必須（`_safe_reflow_and_resize()` 共通関数）。この順序を崩すとスクロールバー誤表示や「縮小が1クリックで反映されない」バグが再発する。
- プリセット幅の計算にはスクロールバー分の幅（`_scrollbar_extent()`）とフレームマージンを必ず含める必要がある（含めないと列数が1つずれてスクロールバーが出る）。
- ボタンの追加・削除・リネーム時のリフローも、プリセット切替と同じ`_safe_reflow_and_resize()`を通す（別経路の`_reflow_and_repair_window()`が独自の古い処理をしていたことが過去のバグ原因）。
- 起動時の`_update_layouts_width()`はセクションごとに`processEvents()`を呼んでいたのを、幅設定を全セクション分まとめてから1回だけ`processEvents()`する方式に変更し高速化済み。
- 既知の制約: `cmds.shelfButton()`のネイティブ生成コストはボタン数に比例し、これ以上の高速化にはMaya標準シェルフウィジェットからの脱却が必要（対応保留）。

---

## edge_tube_tool.py / edgeRope.py / createEdgeTube.py（エッジ沿いチューブ生成）

用途: 選択エッジに沿ってチューブ状ジオメトリを生成する。

設計方針・経緯:
- Parallel Transport Frame + Hermite補間でエッジフローを滑らかにする方式。開いたチェーンでのSカーブ的な歪みは部分対応済み（完全解決ではない）。
- 断面の辺数は可変、プリセットは`optionVar`で保存。
- `createEdgeTube.py`（`ildCreateEdgeTube.py`）は複数の分断されたエッジグループ（マルチチェーン）に対応した派生版。
- 過去に単一チューブ編集モデルが崩れる回帰があり、`edgeTubeData`によるチューブごとのデータ永続化で復元済み。

---

## facialSliderTool.py / compareFacialHierarchy.py（フェイシャルリグ）

用途: ブレンドシェイプのスライダー操作UIと、階層比較ツール。

設計方針・経緯:
- `facialSliderTool.py`: コントローラーごとに折りたたみ可能なセクション、Channel Boxとのリアルタイム同期（ポーリング方式）、スライダードラッグ時の頂点ハイライト。
- ブレンドシェイプのエイリアス名解決（`find_blendshape_weight_plug()`）が肝。
- `compareFacialHierarchy.py`: フェイシャルのブレンドシェイプターゲット階層を比較。
- 既知の未対応事項: プレフィックス除去処理をしないと誤検知（false positive）が出る問題を特定済みだが未実装。

---

## ILDTool_CCS.py（中央集約ツール）

用途: モデリング・カメラ・レンダー関連機能を集約したメインツール。

設計方針・経緯:
- `assignPfxToon`、`openCustomNodeEditor`、`lineInt`透明度トグルなどを統合中。
- リネームセクションのUIは`formLayout`絶対座標から`rowLayout`に移行済み。
- ミラージオメトリのピボット閾値ロジックあり。LRミラー作成時の子ノード順序問題は最終確認時点で未解決。
- FreeCam Adjuster（v1.0.2）、`ildCheckRenderSupport`（v1.0.3、カメラドロップダウンの`rl_lh`自動設定、シーンファイル名からのキャラID自動入力、`keepBorder=0`のスムーズ修正含む）を統合済み。

---

## window_chrome_template_opt_260709.py（共通フレームレスウィンドウテンプレート）

用途: 各ツールに共通のフレームレスウィンドウ外観・挙動を提供する土台。

適用先（約8本）: modelingUtility.py, UVUtility.py, scriptPopupWindow.py, cacheGroup.py, simpleWeightEditor.py, createEdgeTube.py, jointUtility.py, weightUtility.py

設計方針・経緯:
- `_WindowChromeFilter` / `_WindowResizeFilter` / `_MinimizedCloseFilter` が基盤アーキテクチャ。
- マルチウィンドウ時のフィルタ分離のため、ウィンドウごとの辞書キー管理とPySide6 API互換対応が必要。
- `openCustomNodeEditor.py`ではQtウィジェット構築完了をポーリングで待ってからフレームレス化するレースコンディション対策あり。
- Win32ネイティブイベント処理（`WM_NCMBUTTONUP`、`WM_NCLBUTTONDBLCLK`、`GetAsyncKeyState`）で最小化状態の操作に対応。
- `QAbstractNativeEventFilter`はQApplicationシングルトンで状態管理し、リーク防止。
- `_auto_fit_window_height()`: `frameLayout`の`collapseCommand`/`expandCommand`と連動し、内容に応じてウィンドウ高さを自動調整。

---

## ild-submission-prep-tool（納品準備ツール）

用途: バージョン管理されたファイルを、作業フォルダから日付付き出力フォルダへコピーする納品前準備ツール（Python/batch）。

設計方針・経緯:
- `.mb`ファイル、プレイブラスト、AVIファイル、CheckCam、CheckRender画像それぞれに個別のコピーロジックがある。
- 不要ファイルのガベージクリーンアップ機能と、バージョン変更時の警告機能を含む。

---

## fixColorAndAmbient.py（ZZZアセットインポート）

用途: ZZZキャラクターアセットのマテリアル・テクスチャインポート時の調整。

設計方針・経緯:
- `mekage`マテリアルの色ゼロ化、ロックされた接続の切断。
- 過去の作業: 透明度接続の切断、カラーマネジメント設定（`scene-linear Rec.709-sRGB`、`Un-tone-mapped`）。
- テクスチャパスの相対化時、日本語・中国語（漢字）を含むパスのエンコーディング対応が必要（`fixColorAndAmbient.py`に集約済み）。

---

## その他の単発ユーティリティスクリプト

- `assignPfxToon.py`: UI幅の調整、フレームレスウィンドウ組み込み、ウィンドウ自動サイズ調整の修正。
- `freeCamAdjuster.py`: スライダー入力範囲拡張、Set Keyボタン追加、右クリック保存不具合修正（ドラッグ用フィルタがインタラクティブコントロール上の右クリックを横取りしていたのが原因）。
- シーンクリーンアップ系: 名前パターンに基づく不要シェイプノード削除（接続されたOrigノードの安全ガードあり）、未使用ノード削除（ビューポート内HUD通知付き）、名前ベースのマテリアル再割り当て（サフィックス・数字除去マッチング）。
- `merge_images_fac.py`: `lin_fac`/`col_fac`のキャラクターチェック画像をPillowで合成するスクリプト。オフセット配置と背景適用タイミングの調整あり。
- `scriptPopupWindow.py`: カスタムScript Editorウィンドウ。ツールバー再配置、アイコン切り替えボタン、`MQtUtil.findControl()`によるMaya-Qtウィジェット解決。
- Attribute Editor / FreeCam ピボット: AEセクションのスクロール・展開挙動を調査した結果、専用の`freeCamAdjusterWin`スライダーツールに置き換え。`undoInfo(stateWithoutFlush=False)`でUndo抑制。

---

## 全般的な作業ルール

- スクリプトの修正依頼時、無関係な既存コードや機能は変更・削除しない。
- 出力は常にコピペでそのまま差し替え可能な完全版コード。
- コメントアウトで機能を無効化した状態のコードは提示しない。
- UIは高密度・コンパクトを優先。
- 頂点ウェイト調整は整数％への丸めなど精度重視。
- Maya上の左右定義: Left = +X、Right = -X。
- UI状態・設定値はローカル（JSON等）に保存・復元できるようにする。
