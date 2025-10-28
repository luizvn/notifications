import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

export type NotificationDocument = HydratedDocument<Notification>;

export enum NotificationChannel {
    EMAIL = 'email',
    SMS = 'sms',
    PUSH = 'push',
    WHATSAPP = 'whatsapp',
}

export enum NotificationStatus {
    PENDING = 'pending',
    SENT = 'sent',
    FAILED = 'failed',
}

@Schema({ timestamps: true })
export class Notification {
    @Prop({
        type: String,
        required: true,
        index: true,
        unique: true,
        default: () => uuidv4(),
    })
    publicId: string;

    @Prop({
        required: true,
        enum: NotificationChannel,
        index: true,
    })
    channel: NotificationChannel;

    @Prop({
        required: true,
        index: true,
    })
    recipient: string;

    @Prop({ required: true })
    content: string;

    @Prop({
        required: true,
        enum: NotificationStatus,
        default: NotificationStatus.PENDING,
        index: true,
    })
    status: NotificationStatus;

    @Prop()
    failReason?: string
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);