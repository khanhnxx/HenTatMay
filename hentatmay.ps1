Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ========= CẤU HÌNH BIẾN =========
$script:totalSeconds = 120
$script:secondsLeft  = $script:totalSeconds
$barWidth            = 340

# ---- MÀU SẮC (Flat Style) ----
$bgColor    = [Drawing.Color]::FromArgb(30, 30, 30)
$fgColor    = [Drawing.Color]::FromArgb(255, 255, 255)
$barBgColor = [Drawing.Color]::FromArgb(50, 50, 50)
$barColor   = [Drawing.Color]::FromArgb(0, 150, 255)
$btnColor   = [Drawing.Color]::FromArgb(60, 60, 60)
$btnRed     = [Drawing.Color]::FromArgb(200, 50, 50)

# ---- KHỞI TẠO FORM ----
$form = New-Object Windows.Forms.Form
$form.Text = "Hẹn giờ tắt máy"
$form.Size = New-Object Drawing.Size(440, 260)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.BackColor = $bgColor

# ---- LABEL THỜI GIAN ----
$label = New-Object Windows.Forms.Label
$label.Font = New-Object Drawing.Font("Segoe UI", 15, [Drawing.FontStyle]::Bold)
$label.ForeColor = $fgColor
$label.Size = New-Object Drawing.Size(400, 40)
$label.Location = New-Object Drawing.Point(20, 25)
$label.TextAlign = "MiddleCenter"
$form.Controls.Add($label)

# ---- PROGRESS BAR (Dạng phẳng vuông vức) ----
$pbContainer = New-Object Windows.Forms.PictureBox
$pbContainer.Size = New-Object Drawing.Size($barWidth, 16)
$pbContainer.Location = New-Object Drawing.Point([int](($form.ClientSize.Width - $barWidth) / 2), 90)
$pbContainer.BackColor = $barBgColor
$form.Controls.Add($pbContainer)

$pbContainer.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $elapsed = $script:totalSeconds - $script:secondsLeft
    $percent = $elapsed / $script:totalSeconds
    $fillWidth = [int]($pbContainer.Width * $percent)
    
    if ($fillWidth -gt 0) {
        $rectFill = New-Object Drawing.Rectangle(0, 0, $fillWidth, $pbContainer.Height)
        $brush = New-Object Drawing.SolidBrush($barColor)
        $g.FillRectangle($brush, $rectFill)
    }
})

# ---- NÚT BẤM (Đã dịch sang trái: 75->65, 235->225) ----
$btnCancel = New-Object Windows.Forms.Button
$btnCancel.Text = "Huỷ Bỏ"
$btnCancel.Size = New-Object Drawing.Size(130, 40)
$btnCancel.Location = New-Object Drawing.Point(65, 145)
$btnCancel.FlatStyle = "Flat"
$btnCancel.FlatAppearance.BorderSize = 0
$btnCancel.BackColor = $btnColor
$btnCancel.ForeColor = $fgColor
$btnCancel.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$form.Controls.Add($btnCancel)

$btnShutdownNow = New-Object Windows.Forms.Button
$btnShutdownNow.Text = "Tắt Ngay"
$btnShutdownNow.Size = New-Object Drawing.Size(130, 40)
$btnShutdownNow.Location = New-Object Drawing.Point(225, 145)
$btnShutdownNow.FlatStyle = "Flat"
$btnShutdownNow.FlatAppearance.BorderSize = 0
$btnShutdownNow.BackColor = $btnRed
$btnShutdownNow.ForeColor = $fgColor
$btnShutdownNow.Font = New-Object Drawing.Font("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$form.Controls.Add($btnShutdownNow)

# ---- CREDIT (Đã khôi phục) ----
$credit = New-Object Windows.Forms.Label
$credit.Text = "Tạo bởi khanhnx"
$credit.Font = New-Object Drawing.Font("Segoe UI", 8, [Drawing.FontStyle]::Underline)
$credit.ForeColor = [Drawing.Color]::FromArgb(120, 120, 120)
$credit.AutoSize = $true
$credit.Cursor = "Hand"
$form.Controls.Add($credit)

# Căn lề credit vào giữa dưới cùng
$form.Add_Shown({
    $credit.Left = [int](($form.ClientSize.Width - $credit.Width) / 2)
    $credit.Top  = $form.ClientSize.Height - 25
})

$credit.Add_MouseEnter({ $credit.ForeColor = [Drawing.Color]::DeepSkyBlue })
$credit.Add_MouseLeave({ $credit.ForeColor = [Drawing.Color]::FromArgb(120, 120, 120) })
$credit.Add_Click({ Start-Process "https://www.facebook.com/khanhnx01" })

# ---- LOGIC TIMER ----
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 1000

$timer.Add_Tick({
    $script:secondsLeft--
    $label.Text = "Máy tính sẽ tắt sau: $($script:secondsLeft) giây"
    $pbContainer.Invalidate()

    if ($script:secondsLeft -le 0) {
        $timer.Stop()
        Stop-Computer -Force
    }
})

# ---- SỰ KIỆN ----
$btnCancel.Add_Click({
    $timer.Stop()
    $form.Close()
})

$btnShutdownNow.Add_Click({
    $script:totalSeconds = 3
    $script:secondsLeft = 3
    $label.Text = "Đang thực hiện tắt máy..."
    $pbContainer.Invalidate()
})

$form.Add_Shown({
    $label.Text = "Máy tính sẽ tắt sau: $($script:secondsLeft) giây"
    $timer.Start()
})

[void]$form.ShowDialog()