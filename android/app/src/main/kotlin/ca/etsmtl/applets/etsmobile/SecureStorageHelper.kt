package ca.etsmtl.applets.etsmobile

import android.content.Context
import android.util.Base64
import android.util.Log
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.security.KeyStore

class SecureStorageHelper {

    private val keystoreAlias = "ca.etsmtl.applets.etsmobile.FlutterSecureStoragePluginKey"
    private val prefix = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIHNlY3VyZSBzdG9yYWdlCg_"

    fun getValue(context: Context, inputKey: String): String? {
        try {
            val keyStore = KeyStore.getInstance("AndroidKeyStore")
            keyStore.load(null)

            val keyEntry = keyStore.getEntry(keystoreAlias, null) as? KeyStore.PrivateKeyEntry
            if (keyEntry == null) {
                Log.e("SecureStorageHelper", "No PrivateKeyEntry found for alias: $keystoreAlias")
                return null
            }

            val rsaPrivateKey = keyEntry.privateKey
            val rsaCipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
            rsaCipher.init(Cipher.DECRYPT_MODE, rsaPrivateKey)

            val keySharedPreferences =
                context.getSharedPreferences("FlutterSecureKeyStorage", Context.MODE_PRIVATE)
            val encryptedAesKey = keySharedPreferences.all.entries.firstOrNull()?.value as? String
            if (encryptedAesKey == null) {
                Log.e("SecureStorageHelper", "Encryption key not found in FlutterSecureKeyStorage.xml")
                return null
            }

            val decodedEncryptedAesKey = Base64.decode(encryptedAesKey, Base64.DEFAULT)
            val decryptedAesKey = rsaCipher.doFinal(decodedEncryptedAesKey)

            return decryptDataWithAesKey(context, inputKey, decryptedAesKey)

        } catch (e: Exception) {
            Log.e("SecureStorageHelper", "Error while decrypting value", e)
        }
        return null
    }

    private fun decryptDataWithAesKey(context: Context, inputKey: String, aesKey: ByteArray): String? {
        val sharedPreferences =
            context.getSharedPreferences("FlutterSecureStorage", Context.MODE_PRIVATE)

        for (entry in sharedPreferences.all) {
            val plainKey = entry.key

            // Check if the key starts with the known prefix
            if (plainKey.startsWith(prefix)) {
                val actualKey = plainKey.substringAfter(prefix)

                if (actualKey == inputKey) {
                    val encodedValue = entry.value as? String
                    if (encodedValue != null) {
                        val encryptedData = try {
                            Base64.decode(encodedValue, Base64.DEFAULT)
                        } catch (e: IllegalArgumentException) {
                            Log.e("SecureStorageHelper", "Failed to decode value: $encodedValue", e)
                            continue
                        }

                        // Retrieve IV and encrypted data
                        val iv = encryptedData.copyOfRange(0, 16)
                        val actualEncryptedData = encryptedData.copyOfRange(16, encryptedData.size)

                        val aesCipher = Cipher.getInstance("AES/CBC/PKCS7Padding")
                        val secretKeySpec = SecretKeySpec(aesKey, "AES")
                        aesCipher.init(Cipher.DECRYPT_MODE, secretKeySpec, IvParameterSpec(iv))

                        val decryptedValue = aesCipher.doFinal(actualEncryptedData)
                        return String(decryptedValue)
                    }
                }
            } else {
                Log.d("SecureStorageHelper", "Key does not match the expected prefix: $plainKey")
            }
        }
        return null
    }
}