import { Injectable, signal } from '@angular/core';

export type UserRole = 'patient' | 'clinician' | 'admin';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private roleSig = signal<UserRole | null>(null);
  private consentSig = signal<string | null>(null);
  private patientIdSig = signal<string | null>(null);

  setRole(role: UserRole) {
    this.roleSig.set(role);
  }

  logout() {
    this.roleSig.set(null);
    this.consentSig.set(null);
    this.patientIdSig.set(null);
  }

  currentRole() {
    return this.roleSig();
  }

  setConsent(patientId: string, consentToken: string) {
    this.patientIdSig.set(patientId);
    this.consentSig.set(consentToken);
  }

  hasConsent() {
    return !!this.consentSig();
  }

  getConsentToken() {
    return this.consentSig();
  }

  getPatientId() {
    return this.patientIdSig();
  }
}

