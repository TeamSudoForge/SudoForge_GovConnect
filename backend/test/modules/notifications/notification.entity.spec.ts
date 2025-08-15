import { Notification } from '../../../src/modules/notifications/notification.entity';
import { User } from '../../../src/modules/users/entities/user.entity';

describe('Notification Entity', () => {
  it('should create a notification with default values', () => {
    const user = new User();
    user.id = 'user-uuid';
    const notification = new Notification();
    notification.title = 'Test Title';
    notification.body = 'Test Body';
    notification.data = 'Extra Data';
    notification.user = user;

    expect(notification.title).toBe('Test Title');
    expect(notification.body).toBe('Test Body');
    expect(notification.data).toBe('Extra Data');
    expect(notification.read).toBe(false); // default value
    expect(notification.user).toBe(user);
  });

  it('should allow marking as read', () => {
    const notification = new Notification();
    notification.read = true;
    expect(notification.read).toBe(true);
  });
});
