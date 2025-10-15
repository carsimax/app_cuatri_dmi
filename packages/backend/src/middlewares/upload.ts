import { Request, Response, NextFunction } from 'express';
import { uploadSingle, uploadMultiple, uploadFields, handleMulterError } from '../config/multer';
import { createSuccessResponse, createErrorResponse } from '../models/ApiResponse';

// Middleware para upload de un solo archivo
export const uploadSingleFile = (req: any, res: any, next: any) => {
  uploadSingle(req, res, (err: any) => {
    if (err) {
      return handleMulterError(err, req, res, next);
    }
    next();
  });
};

// Middleware para upload de múltiples archivos
export const uploadMultipleFiles = (req: any, res: any, next: any) => {
  uploadMultiple(req, res, (err: any) => {
    if (err) {
      return handleMulterError(err, req, res, next);
    }
    next();
  });
};

// Middleware para upload de campos específicos
export const uploadSpecificFields = (req: any, res: any, next: any) => {
  uploadFields(req, res, (err: any) => {
    if (err) {
      return handleMulterError(err, req, res, next);
    }
    next();
  });
};

// Helper para procesar archivos subidos y devolver información útil
export const processUploadedFiles = (files: any) => {
  if (!files) return null;

  // Si es un solo archivo
  if (files.filename) {
    return {
      filename: files.filename,
      originalName: files.originalname,
      size: files.size,
      mimetype: files.mimetype,
      path: files.path,
      url: `/uploads/${files.filename}`
    };
  }

  // Si son múltiples archivos
  if (Array.isArray(files)) {
    return files.map(file => ({
      filename: file.filename,
      originalName: file.originalname,
      size: file.size,
      mimetype: file.mimetype,
      path: file.path,
      url: `/uploads/${file.filename}`
    }));
  }

  // Si son campos específicos
  if (typeof files === 'object') {
    const processed: any = {};
    Object.keys(files).forEach(fieldName => {
      const fieldFiles = (files as any)[fieldName];
      if (Array.isArray(fieldFiles)) {
        processed[fieldName] = fieldFiles.map(file => ({
          filename: file.filename,
          originalName: file.originalname,
          size: file.size,
          mimetype: file.mimetype,
          path: file.path,
          url: `/uploads/${file.filename}`
        }));
      } else if (fieldFiles) {
        processed[fieldName] = {
          filename: fieldFiles.filename,
          originalName: fieldFiles.originalname,
          size: fieldFiles.size,
          mimetype: fieldFiles.mimetype,
          path: fieldFiles.path,
          url: `/uploads/${fieldFiles.filename}`
        };
      }
    });
    return processed;
  }

  return null;
};

// Middleware para servir archivos estáticos (agregar a index.ts)
export const setupStaticFiles = (app: any) => {
  const express = require('express');
  const path = require('path');
  
  // Crear directorio uploads si no existe
  const fs = require('fs');
  const uploadsDir = path.join(__dirname, '../../uploads');
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
  }
  
  // Servir archivos estáticos desde /uploads
  (app as any).use('/uploads', express.static(uploadsDir));
};
