import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lineInput", "timer", "progressBar", "titleInput"]
  static values = {
    memoId: Number,
    timeLimit: { type: Number, default: 60 },
    autoSubmitUrl: String
  }

  connect() {
    console.log(`[MemoEditor] connect() - MemoID: ${this.memoIdValue}, TimeLimit: ${this.timeLimitValue}`)
    this.currentLineIndex = 0
    this.startTime = Date.now()
    this.timerInterval = null
    this.isSubmitting = false  // 二重送信防止フラグ
    this.setupFocusMode()
    this.startTimer()
    this.preventBackwardNavigation()
  }

  disconnect() {
    console.log(`[MemoEditor] disconnect() - MemoID: ${this.memoIdValue}`)
    if (this.timerInterval) clearInterval(this.timerInterval)
  }

  // === タイマー管理 ===
  startTimer() {
    console.log(`[MemoEditor] startTimer() - Starting timer for memo ${this.memoIdValue}`)
    this.timerInterval = setInterval(() => {
      const elapsed = Math.floor((Date.now() - this.startTime) / 1000)
      const remaining = this.timeLimitValue - elapsed

      // プログレスバー更新
      const progress = (elapsed / this.timeLimitValue) * 100
      this.progressBarTarget.style.width = `${progress}%`

      if (remaining <= 0) {
        console.log(`[MemoEditor] Timer expired for memo ${this.memoIdValue}. Calling timeUp()`)
        this.timeUp()
      }
    }, 100)
  }

  timeUp() {
    console.log(`[MemoEditor] timeUp() - MemoID: ${this.memoIdValue}, isSubmitting: ${this.isSubmitting}`)
    if (this.isSubmitting) {
      console.log(`[MemoEditor] Already submitting, skipping duplicate timeUp()`)
      return
    }
    this.isSubmitting = true
    clearInterval(this.timerInterval)
    // 現在入力中の行を強制保存
    this.saveCurrentLine(() => {
      // タイトル保存 + 次ページへ遷移
      this.submitMemo()
    })
  }

  // === キー制御 ===
  handleKeydown(event) {
    const input = event.target

    // Tabキー: 行確定
    if (event.key === "Tab") {
      event.preventDefault()
      this.confirmLine(input)
      return
    }

    // Enterキー: IME確定のみ（改行禁止）
    if (event.key === "Enter" && !event.isComposing) {
      event.preventDefault()
      return
    }

    // Backspace: 行頭で無効化
    if (event.key === "Backspace" && input.selectionStart === 0) {
      event.preventDefault()
      return
    }

    // 上矢印/PageUp: 完全ブロック
    if (["ArrowUp", "PageUp"].includes(event.key)) {
      event.preventDefault()
      return
    }
  }

  // === 行の確定と保存 ===
  confirmLine(input) {
    const content = input.value.trim()
    if (content.length === 0) return

    // readonly化
    input.readOnly = true
    input.classList.add("confirmed")
    input.tabIndex = -1
    input.style.pointerEvents = "none"

    // バックエンドへ非同期保存
    this.saveLine(content, this.currentLineIndex + 1, () => {
      // 次の行を生成
      this.createNextLine()
    })
  }

  saveLine(content, rowOrder, callback) {
    console.log(`[MemoEditor] saveLine() - MemoID: ${this.memoIdValue}, rowOrder: ${rowOrder}`)
    fetch(`/memos/${this.memoIdValue}/lines`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getCsrfToken()
      },
      body: JSON.stringify({
        line: { content: content, row_order: rowOrder }
      })
    })
      .then(response => response.json())
      .then(data => {
        console.log(`[MemoEditor] saveLine response:`, data)
        if (data.status === "saved") {
          callback()
        } else {
          alert("保存に失敗しました: " + data.errors.join(", "))
        }
      })
      .catch(error => {
        console.error("Save error:", error)
        alert("ネットワークエラーが発生しました")
      })
  }

  saveCurrentLine(callback) {
    console.log(`[MemoEditor] saveCurrentLine() - currentLineIndex: ${this.currentLineIndex}`)
    const currentInput = this.lineInputTargets[this.currentLineIndex]
    if (currentInput && currentInput.value.trim().length > 0) {
      this.confirmLine(currentInput)
      setTimeout(callback, 300) // 保存完了を待つ
    } else {
      console.log(`[MemoEditor] No content to save, calling callback immediately`)
      callback()
    }
  }

  createNextLine() {
    const container = this.element.querySelector(".lines-container")
    const newInput = document.createElement("input")
    newInput.type = "text"
    newInput.className = "line-input"
    newInput.dataset.memoEditorTarget = "lineInput"
    newInput.dataset.action = "keydown->memo-editor#handleKeydown"

    container.appendChild(newInput)
    this.currentLineIndex++
    newInput.focus()
  }

  // === ページ遷移 ===
  submitMemo() {
    const title = this.titleInputTarget.value.trim()
    console.log(`[MemoEditor] submitMemo() - MemoID: ${this.memoIdValue}, Title: "${title}"`)

    fetch(`/memos/${this.memoIdValue}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getCsrfToken()
      },
      body: JSON.stringify({ memo: { title: title } })
    })
      .then(response => {
        console.log(`[MemoEditor] submitMemo response - redirected: ${response.redirected}, url: ${response.url}`)
        if (response.redirected) {
          // CSS遷移アニメーション
          document.body.classList.add("page-transition")
          setTimeout(() => {
            console.log(`[MemoEditor] Navigating to: ${response.url}`)
            window.location.href = response.url
          }, 300)
        } else {
          console.log(`[MemoEditor] Response was NOT redirected. Status: ${response.status}`)
        }
      })
      .catch(error => {
        console.error(`[MemoEditor] submitMemo error:`, error)
      })
  }

  // === フォーカスモード ===
  setupFocusMode() {
    document.body.classList.add("focus-mode")
  }

  preventBackwardNavigation() {
    // ブラウザバック禁止
    history.pushState(null, null, location.href)
    window.addEventListener("popstate", () => {
      history.pushState(null, null, location.href)
      alert("セッション中は前のページに戻れません")
    })
  }

  getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}
