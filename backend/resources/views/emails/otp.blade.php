<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background:#f5f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f5f6f8;padding:32px 0;">
    <tr><td align="center">
      <table role="presentation" width="440" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;max-width:440px;">
        <tr><td style="background:linear-gradient(135deg,#FB923C,#F97316);padding:26px 32px;">
          <span style="color:#ffffff;font-size:22px;font-weight:bold;">ShopSphere</span>
        </td></tr>
        <tr><td style="padding:32px;">
          <p style="margin:0 0 8px;color:#14140f;font-size:18px;font-weight:bold;">{{ $subjectLine }}</p>
          <p style="margin:0 0 24px;color:#6b7280;font-size:14px;line-height:1.6;">{{ $intro }}</p>
          <div style="background:#fff7ed;border:1px solid #fed7aa;border-radius:12px;padding:18px;text-align:center;">
            <span style="color:#ea580c;font-size:34px;font-weight:bold;letter-spacing:10px;">{{ $code }}</span>
          </div>
          <p style="margin:24px 0 0;color:#9aa0aa;font-size:12px;line-height:1.6;">This code expires in 15 minutes. If you didn't request it, you can safely ignore this email.</p>
        </td></tr>
        <tr><td style="padding:18px 32px;border-top:1px solid #eef0f2;">
          <span style="color:#9aa0aa;font-size:12px;">&copy; {{ date('Y') }} ShopSphere</span>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
