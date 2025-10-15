import bcrypt from 'bcrypt';

/**
 * Número de rounds para bcrypt (10 es un buen balance entre seguridad y performance)
 */
const SALT_ROUNDS = 10;

/**
 * Genera un hash de la contraseña usando bcrypt
 * @param password - Contraseña en texto plano
 * @returns Hash de la contraseña
 */
export const hashPassword = async (password: string): Promise<string> => {
  try {
    const salt = await bcrypt.genSalt(SALT_ROUNDS);
    const hashedPassword = await bcrypt.hash(password, salt);
    return hashedPassword;
  } catch (error) {
    throw new Error('Error al hashear la contraseña');
  }
};

/**
 * Compara una contraseña en texto plano con su hash
 * @param plainPassword - Contraseña en texto plano
 * @param hashedPassword - Hash de la contraseña
 * @returns true si las contraseñas coinciden, false en caso contrario
 */
export const comparePassword = async (
  plainPassword: string, 
  hashedPassword: string
): Promise<boolean> => {
  try {
    return await bcrypt.compare(plainPassword, hashedPassword);
  } catch (error) {
    throw new Error('Error al comparar contraseñas');
  }
};

/**
 * Valida que una contraseña cumpla con los requisitos de seguridad
 * @param password - Contraseña a validar
 * @returns true si es válida, false en caso contrario
 */
export const validatePasswordStrength = (password: string): boolean => {
  // Mínimo 6 caracteres
  if (password.length < 6) {
    return false;
  }

  // Al menos una letra
  if (!/[a-zA-Z]/.test(password)) {
    return false;
  }

  // Al menos un número
  if (!/\d/.test(password)) {
    return false;
  }

  return true;
};

/**
 * Genera una contraseña temporal aleatoria
 * @param length - Longitud de la contraseña (default: 12)
 * @returns Contraseña aleatoria
 */
export const generateTemporaryPassword = (length: number = 12): string => {
  const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  let password = '';
  
  // Asegurar al menos un carácter de cada tipo
  const lowercase = 'abcdefghijklmnopqrstuvwxyz';
  const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  const symbols = '!@#$%^&*';
  
  password += lowercase[Math.floor(Math.random() * lowercase.length)];
  password += uppercase[Math.floor(Math.random() * uppercase.length)];
  password += numbers[Math.floor(Math.random() * numbers.length)];
  password += symbols[Math.floor(Math.random() * symbols.length)];
  
  // Completar con caracteres aleatorios
  for (let i = 4; i < length; i++) {
    password += charset[Math.floor(Math.random() * charset.length)];
  }
  
  // Mezclar los caracteres
  return password.split('').sort(() => Math.random() - 0.5).join('');
};
