<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class OtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $subjectLine,
        public string $intro,
        public string $code,
    ) {
    }

    public function build(): self
    {
        return $this->subject($this->subjectLine)->view('emails.otp')->with([
            'subjectLine' => $this->subjectLine,
            'intro' => $this->intro,
            'code' => $this->code,
        ]);
    }
}
