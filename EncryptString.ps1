﻿Function EncryptString {
    <#
    .SYNOPSIS
    Encrypt a string with it's password.
    
    .DESCRIPTION
    With this simple function you can encrypt a string with it's key, something like 'public/private'(PKI). Also reuse defined Key in a decrypt form.
    
    .PARAMETER Key
    Mandatory - your password with which you will encrypt your string. Don't forget your key because it's used for decryption.
    .PARAMETER UnencryptedString
    Mandatory - actual string you wanna encrypt with your corresponding key.
    .PARAMETER KeySize
    NotMandatory - define your key size here, recommended is already defined. 
    .PARAMETER BlockSize
    NotMandatory - define your block size here, default is 128. 
    .PARAMETER Mode
    NotMandatory - choose cipher mode, default is CBC.  
    .PARAMETER Padding
    NotMandatory - choose padding mode, default is set to Zeros.
    
    .EXAMPLE
    EncryptString -Key 'my_private_password' -UnencryptedString 'my_string_to_encrypt'
    
    .NOTES
    v1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$UnencryptedString,

        [Parameter(Mandatory = $false)]
        [int]$KeySize = 256,

        [Parameter(Mandatory = $false)]
        [int]$BlockSize = 128,

        [Parameter(Mandatory = $false)]
        [ValidateSet('CBC', 'CFB', 'CTS', 'ECB', 'OFB', 'CTS', 'CTS', 'CTS')]
        $Mode = 'CBC',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Zeros', 'ANSIX923', 'ISO10126', 'PKCS7', 'None')]
        $Padding = 'Zeros'
    )
    BEGIN {
        $ShaManaged = New-Object System.Security.Cryptography.SHA256Managed
        $AesManaged = New-Object System.Security.Cryptography.AesManaged
    }
    PROCESS {
        $AesManaged.Mode = [System.Security.Cryptography.CipherMode]::$Mode
        $AesManaged.Padding = [System.Security.Cryptography.PaddingMode]::$Padding
        $AesManaged.BlockSize = $BlockSize
        $AesManaged.KeySize = $KeySize
        $AesManaged.GenerateKey()
        $AesManaged.Key = $ShaManaged.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))
        $PlainBytes = [System.Text.Encoding]::UTF8.GetBytes($UnencryptedString)
        $Encryptor = $AesManaged.CreateEncryptor()
        $EncryptedBytes = $Encryptor.TransformFinalBlock($PlainBytes, 0, $PlainBytes.Length)
        $EncryptedBytes = $AesManaged.IV + $EncryptedBytes
        $PublicKey = [System.Convert]::ToBase64String($EncryptedBytes)
    }
    END {
        $AesManaged.Dispose()
        Write-Output "Plaintext string: $Key"
        Write-Output "Encrypted string: $PublicKey"
    }
}