import { Request, Response } from 'express';
import { asyncHandler, createError } from '../middlewares/errorHandler';
import { createSuccessResponse } from '../models/ApiResponse';
import { firebaseMessaging } from '../config/firebase';
import { prisma } from '../config/database';

export const sendNotification = asyncHandler(async (req: Request, res: Response) => {
  const { usuarioId, title, body, data } = req.body;

  // Obtener tokens FCM del usuario
  const usuario = await prisma.usuario.findUnique({
    where: { id: usuarioId },
    select: { fcmTokens: true },
  });

  if (!usuario || !usuario.fcmTokens) {
    throw createError('Usuario no tiene tokens FCM registrados', 404, 'NO_FCM_TOKENS');
  }

  let tokens: string[] = [];
  try {
    tokens = JSON.parse(usuario.fcmTokens);
  } catch (e) {
    throw createError('Error al parsear tokens FCM', 500, 'PARSE_ERROR');
  }

  if (tokens.length === 0) {
    throw createError('No hay tokens FCM para este usuario', 404, 'NO_TOKENS');
  }

  // Enviar notificación a todos los dispositivos del usuario
  const message = {
    notification: {
      title,
      body,
    },
    data: data || {},
    tokens,
  };

  const response = await firebaseMessaging.sendEachForMulticast(message);

  res.json(createSuccessResponse(
    { successCount: response.successCount, failureCount: response.failureCount },
    'Notificación enviada'
  ));
});