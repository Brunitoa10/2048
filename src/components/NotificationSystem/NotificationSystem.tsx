import { useState, useEffect } from 'react';

export interface Notification {
  id: number;
  type: 'combo' | 'newMaximum' | 'points' | 'blockRetired' | 'newBlockAdded' | 'boostExpired';
  message: string;
  value?: number;
}

interface NotificationSystemProps {
  notifications: Notification[];
  onRemove: (id: number) => void;
}

function NotificationSystem({ notifications, onRemove }: NotificationSystemProps) {
  useEffect(() => {
    notifications.forEach(notification => {
      const timer = setTimeout(() => {
        onRemove(notification.id);
      }, 3000);
      
      return () => clearTimeout(timer);
    });
  }, [notifications, onRemove]);

  return (
    <div className="notification-container">
      {notifications.map(notification => (
        <div 
          key={notification.id} 
          className={`notification notification-${notification.type}`}
          onClick={() => onRemove(notification.id)}
        >
          {notification.type === 'combo' && (
            <>
              <span className="notification-text">Combo x{notification.value}!</span>
            </>
          )}
          {notification.type === 'newMaximum' && (
            <>
              <span className="notification-icon">🏆</span>
              <span className="notification-text">¡Nuevo máximo: {notification.value}!</span>
            </>
          )}
          {notification.type === 'points' && (
            <>
              <span className="notification-text">+{notification.value} puntos</span>
            </>
          )}
          {notification.type === 'blockRetired' && (
            <>
              <span className="notification-icon">🗑️</span>
              <span className="notification-text">Bloque {notification.value} retirado</span>
            </>
          )}
          {notification.type === 'newBlockAdded' && (
            <>
              <span className="notification-icon">✨</span>
              <span className="notification-text">Nuevo bloque: {notification.value}</span>
            </>
          )}
          {notification.type === 'boostExpired' && (
            <>
              <span className="notification-icon">⏰</span>
              <span className="notification-text">{notification.message}</span>
            </>
          )}
        </div>
      ))}
    </div>
  );
}

export default NotificationSystem;