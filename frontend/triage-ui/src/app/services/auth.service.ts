import { Injectable, inject, signal, computed } from '@angular/core';
import { AuthService as Auth0Service } from '@auth0/auth0-angular';
import { map, Observable, of, switchMap } from 'rxjs';
import { toSignal } from '@angular/core/rxjs-interop';

export type UserRole = 'patient' | 'clinician' | 'admin';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private auth0 = inject(Auth0Service);

  // Auth0 observables converted to signals
  isAuthenticated = toSignal(this.auth0.isAuthenticated$, { initialValue: false });
  isLoading = toSignal(this.auth0.isLoading$, { initialValue: true });
  user = toSignal(this.auth0.user$, { initialValue: null });

  // Local state for consent flow
  private consentSig = signal<string | null>(null);
  private patientIdSig = signal<string | null>(null);

  // Computed role from Auth0 user metadata or custom claims
  currentRole = computed<UserRole | null>(() => {
    const user = this.user();
    if (!user) return null;

    // Auth0 custom claims namespace (configure in Auth0 Actions/Rules)
    const namespace = 'https://medical-insights.com/';
    const roles = user[`${namespace}roles`] as string[] | undefined;

    if (roles?.includes('admin')) return 'admin';
    if (roles?.includes('clinician')) return 'clinician';
    if (roles?.includes('patient')) return 'patient';

    // Return null if no role is assigned - don't default to patient
    return null;
  });

  // Get access token for API calls
  getAccessToken$(): Observable<string> {
    return this.auth0.getAccessTokenSilently();
  }

  // Login with redirect
  // Note: The role parameter is only for UI purposes (which button was clicked)
  // The actual user role comes from Auth0 token claims after login
  login(role?: UserRole): void {
    // Always redirect to home after login, let the app determine where to go based on actual user role
    this.auth0.loginWithRedirect({
      appState: { target: '/' },
    });
  }

  // Logout
  logout(): void {
    // Clear local state first
    this.consentSig.set(null);
    this.patientIdSig.set(null);
    
    // Clear Auth0 cache from localStorage
    const auth0Keys = Object.keys(localStorage).filter(key => 
      key.startsWith('@@auth0spajs@@') || 
      key.startsWith('auth0') ||
      key.includes('auth0')
    );
    auth0Keys.forEach(key => localStorage.removeItem(key));
    
    // Logout from Auth0 and redirect to home
    this.auth0.logout({
      logoutParams: {
        returnTo: window.location.origin,
      },
    });
  }

  // Consent management (unchanged from original)
  setConsent(patientId: string, consentToken: string): void {
    this.patientIdSig.set(patientId);
    this.consentSig.set(consentToken);
  }

  hasConsent(): boolean {
    return !!this.consentSig();
  }

  getConsentToken(): string | null {
    return this.consentSig();
  }

  getPatientId(): string | null {
    return this.patientIdSig();
  }

  // Check if user has required role
  hasRole(requiredRole: UserRole): boolean {
    const role = this.currentRole();
    if (!role) return false;

    // Admin has access to everything
    if (role === 'admin') return true;

    return role === requiredRole;
  }
}
