import { Router } from 'express';
import { sendNotification } from '../controllers/notificationController';
import { authenticate } from '../middlewares/auth';

const router = Router();

router.post('/send', authenticate, sendNotification);

export default router;