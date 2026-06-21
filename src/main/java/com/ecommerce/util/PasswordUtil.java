package com.ecommerce.util;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Arrays;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.MessageDigest;

public class PasswordUtil {

    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256; // bits
    private static final int SALT_LENGTH = 16; // bytes
    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";

    /**
     * Hash a password using PBKDF2 with a dynamically generated salt.
     * Output format: ITERATIONS:HEX_SALT:HEX_HASH
     */
    public static String hashPassword(String password) {
        SecureRandom sr = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        sr.nextBytes(salt);

        byte[] hash = pbkdf2(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
        return ITERATIONS + ":" + toHex(salt) + ":" + toHex(hash);
    }

    /**
     * Check if the input password matches the stored hash (supports both PBKDF2 and legacy SHA-256 fallback).
     */
    public static boolean checkPassword(String inputPassword, String storedHash) {
        if (storedHash == null || inputPassword == null) {
            return false;
        }

        // Check if it's the legacy SHA-256 hash (64 hex characters, no colons)
        if (storedHash.length() == 64 && !storedHash.contains(":")) {
            return hashSHA256Fallback(inputPassword).equalsIgnoreCase(storedHash);
        }

        // Parse PBKDF2 components
        String[] parts = storedHash.split(":");
        if (parts.length != 3) {
            return false;
        }

        try {
            int iterations = Integer.parseInt(parts[0]);
            byte[] salt = fromHex(parts[1]);
            byte[] hash = fromHex(parts[2]);

            byte[] testHash = pbkdf2(inputPassword.toCharArray(), salt, iterations, hash.length * 8);
            return slowEquals(hash, testHash);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return false;
        }
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength) {
        PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
        try {
            SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGORITHM);
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Error hashing password with PBKDF2", e);
        } finally {
            spec.clearPassword();
        }
    }

    private static boolean slowEquals(byte[] a, byte[] b) {
        int diff = a.length ^ b.length;
        for (int i = 0; i < a.length && i < b.length; i++) {
            diff |= a[i] ^ b[i];
        }
        return diff == 0;
    }

    private static String toHex(byte[] array) {
        StringBuilder sb = new StringBuilder();
        for (byte b : array) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    private static byte[] fromHex(String hex) {
        byte[] bytes = new byte[hex.length() / 2];
        for (int i = 0; i < bytes.length; i++) {
            bytes[i] = (byte) Integer.parseInt(hex.substring(2 * i, 2 * i + 2), 16);
        }
        return bytes;
    }

    /**
     * Fallback SHA-256 hashing method for backward compatibility
     */
    private static String hashSHA256Fallback(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }
}
