import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Observable } from 'rxjs';
import { SymptomPayload, TriageResult } from '../types';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private http = inject(HttpClient);
  private base = environment.apiBaseUrl;

  createEncounter(patientId: string, consentToken: string): Observable<{ encounterId: string }> {
    return this.http.post<{ encounterId: string }>(`${this.base}/encounters`, {
      patientId,
      consentToken,
    });
  }

  submitSymptoms(encounterId: string, payload: SymptomPayload): Observable<void> {
    return this.http.post<void>(`${this.base}/encounters/${encounterId}/symptoms`, payload);
  }

  triage(encounterId: string): Observable<TriageResult> {
    return this.http.post<TriageResult>(`${this.base}/encounters/${encounterId}/triage`, {});
  }

  clinicianReview(
    encounterId: string,
    payload: { decision: string; notes?: string; reviewer: string }
  ): Observable<void> {
    return this.http.post<void>(`${this.base}/encounters/${encounterId}/clinician-review`, payload);
  }
}

