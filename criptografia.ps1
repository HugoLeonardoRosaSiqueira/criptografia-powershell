function New-RandomBytes {
    param(
        [int]$Length = 16
    )
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $bytes = New-Object byte[] $Length
    $rng.GetBytes($bytes)
    return $bytes
}

function Get-AesKeyFromPassword {
    param(
        [Parameter(Mandatory=$true)][SecureString]$Password,
        [Parameter(Mandatory=$true)][byte[]]$Salt,
        [int]$KeySize = 32,         # 32 bytes = 256 bits
        [int]$Iterations = 100000   # custo do PBKDF2 (pode ajustar)
    )

    # Converte SecureString para texto temporariamente
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)

    try {
        # PBKDF2
        $kdf = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($plainPassword, $Salt, $Iterations)
        return $kdf.GetBytes($KeySize)
    }
    finally {
        # limpa da memória
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Protect-Text {
    param(
        [Parameter(Mandatory=$true)][string]$PlainText,
        [Parameter(Mandatory=$true)][SecureString]$Password
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    $salt = New-RandomBytes -Length 16
    $key = Get-AesKeyFromPassword -Password $Password -Salt $salt -KeySize ($aes.KeySize / 8)
    $aes.Key = $key
    $aes.GenerateIV()

    $encryptor = $aes.CreateEncryptor()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $cipherBytes = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length)

    # Retorna salt + IV + dados criptografados
    return ,($salt + $aes.IV + $cipherBytes)
}

function Unprotect-Text {
    param(
        [Parameter(Mandatory=$true)][byte[]]$CipherText,
        [Parameter(Mandatory=$true)][SecureString]$Password
    )

    $aes = [System.Security.Cryptography.Aes]::Create()

    # extrai salt e IV
    $salt = $CipherText[0..15]
    $iv = $CipherText[16..31]
    $realCipher = $CipherText[32..($CipherText.Length-1)]

    $key = Get-AesKeyFromPassword -Password $Password -Salt $salt -KeySize ($aes.KeySize / 8)
    $aes.Key = $key
    $aes.IV = $iv

    $decryptor = $aes.CreateDecryptor()
    $plainBytes = $decryptor.TransformFinalBlock($realCipher, 0, $realCipher.Length)

    return [System.Text.Encoding]::UTF8.GetString($plainBytes)
}

# ---------------- TESTE ----------------

# pede senha de forma segura
$Password = Read-Host "Digite sua senha" -AsSecureString

# exemplo de texto
$texto = "Mensagem secreta do Hugo"

# criptografa
$encrypted = Protect-Text -PlainText $texto -Password $Password
Write-Host "Criptografado (bytes): $([System.Convert]::ToBase64String($encrypted))"

# descriptografa
$decrypted = Unprotect-Text -CipherText $encrypted -Password $Password
Write-Host "Decriptografado: $decrypted"