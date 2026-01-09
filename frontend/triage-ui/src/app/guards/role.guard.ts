import { CanMatchFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService, UserRole } from '../services/auth.service';

export const roleGuard = (allowed: UserRole[]): CanMatchFn => {
  return () => {
    const auth = inject(AuthService);
    const router = inject(Router);
    const role = auth.currentRole();
    if (!role || !allowed.includes(role)) {
        router.navigateByUrl('/not-authorized');
        return false;
    }
    return true;
  };
};

