import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Observable } from 'rxjs';
import { SymptomPayload, TriageResult, EncounterResponse, ClinicianReviewPayload } from '../types';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private http = inject(HttpClient);
  private base = environment.apiBaseUrl;

  createEncounter(patientId: string, consentToken: string, sourceChannel?: string): Observable<EncounterResponse> {
    const headers = new HttpHeaders();
    if (sourceChannel) {
      headers.set('X-Source-Channel', sourceChannel);
    }
    return this.http.post<EncounterResponse>(
      `${this.base}/encounters`,
      { patientId, consentToken },
      { headers }
    );
  }

  submitSymptoms(encounterId: string, payload: SymptomPayload): Observable<void> {
    return this.http.post<void>(`${this.base}/encounters/${encounterId}/symptoms`, payload);
  }

  triage(encounterId: string, traceId?: string): Observable<TriageResult> {
    const headers = new HttpHeaders();
    if (traceId) {
      headers.set('X-Trace-Id', traceId);
    }
    return this.http.post<TriageResult>(
      `${this.base}/encounters/${encounterId}/triage`,
      {},
      { headers }
    );
  }

  clinicianReview(encounterId: string, payload: ClinicianReviewPayload): Observable<void> {
    return this.http.post<void>(`${this.base}/encounters/${encounterId}/clinician-review`, payload);
  }

  getEncounter(encounterId: string): Observable<EncounterResponse> {
    return this.http.get<EncounterResponse>(`${this.base}/encounters/${encounterId}`);
  }

  getEncountersByPatient(patientId: string): Observable<EncounterResponse[]> {
    return this.http.get<EncounterResponse[]>(`${this.base}/encounters/patient/${patientId}`);
  }
}

