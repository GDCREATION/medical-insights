import { CanMatchFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const consentGuard: CanMatchFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (!auth.hasConsent()) {
    router.navigateByUrl('/consent');
    return false;
  }
  return true;
};

