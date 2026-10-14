import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpStatus,
  HttpCode,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { NotificationsService } from '../notifications.service';
import { RegisterFcmTokenDto, RemoveFcmTokenDto } from '../dto/register-fcm-token.dto';

@ApiTags('Notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('fcm-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Register or refresh an FCM device token' })
  @ApiResponse({ status: 200, description: 'Token registered successfully.' })
  async registerFcmToken(
    @CurrentUser('id') userId: string,
    @Body() dto: RegisterFcmTokenDto,
  ) {
    const result = await this.notificationsService.registerToken(
      userId,
      dto.token,
      dto.deviceType,
    );
    return {
      success: true,
      message: 'FCM token registered successfully',
      data: result,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete('fcm-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Remove an FCM device token on logout' })
  @ApiResponse({ status: 200, description: 'Token removed successfully.' })
  async removeFcmToken(@Body() dto: RemoveFcmTokenDto) {
    await this.notificationsService.removeToken(dto.token);
    return {
      success: true,
      message: 'FCM token removed successfully',
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get paginated notifications for current user' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getUserNotifications(
    @CurrentUser('id') userId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const pageNum = page ? parseInt(page, 10) : 1;
    const limitNum = limit ? parseInt(limit, 10) : 20;

    const data = await this.notificationsService.getUserNotifications(
      userId,
      pageNum,
      limitNum,
    );

    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('unread-count')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get unread notifications count for badge' })
  async getUnreadCount(@CurrentUser('id') userId: string) {
    const unreadCount = await this.notificationsService.getUnreadCount(userId);
    return {
      success: true,
      data: { unreadCount },
      statusCode: HttpStatus.OK,
    };
  }

  @Patch(':id/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark a notification as read' })
  async markAsRead(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    const data = await this.notificationsService.markAsRead(userId, id);
    return {
      success: true,
      message: 'Notification marked as read',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Patch('read-all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all notifications as read' })
  async markAllAsRead(@CurrentUser('id') userId: string) {
    await this.notificationsService.markAllAsRead(userId);
    return {
      success: true,
      message: 'All notifications marked as read',
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a notification' })
  async deleteNotification(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    await this.notificationsService.deleteNotification(userId, id);
    return {
      success: true,
      message: 'Notification deleted successfully',
      statusCode: HttpStatus.OK,
    };
  }
}
