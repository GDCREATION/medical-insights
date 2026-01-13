import { CanMatchFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService, UserRole } from '../services/auth.service';
import { AuthService as Auth0Service } from '@auth0/auth0-angular';
import { map, take } from 'rxjs';

export const roleGuard = (allowed: UserRole[]): CanMatchFn => {
  return () => {
    const auth = inject(AuthService);
    const auth0 = inject(Auth0Service);
    const router = inject(Router);

    // Wait for Auth0 to finish loading
    return auth0.isLoading$.pipe(
      take(1),
      map(() => {
        // Check if authenticated first
        if (!auth.isAuthenticated()) {
          // Redirect to login
          auth.login();
          return false;
        }

        const role = auth.currentRole();
        if (!role || !allowed.includes(role)) {
          router.navigateByUrl('/not-authorized');
          return false;
        }
        return true;
      })
    );
  };
};
