import { Component, inject } from '@angular/core';
import { FormArray, FormBuilder, FormControl, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';
import { SymptomPayload, TriageResult } from '../../types';
import { firstValueFrom } from 'rxjs';

@Component({
  selector: 'app-patient-triage',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './patient-triage.component.html',
  styleUrls: ['./patient-triage.component.scss'],
})
export class PatientTriageComponent {
  private fb = inject(FormBuilder);
  private api = inject(ApiService);
  private auth = inject(AuthService);

  encounterId: string | null = null;
  triageResult: TriageResult | null = null;
  loading = false;
  error: string | null = null;

  form = this.fb.group({
    symptoms: this.fb.array<FormControl<string>>([
      this.fb.control('', { nonNullable: true, validators: [Validators.required] }),
    ]),
    freeText: [''],
    pregnancyFlag: [null],
  });

  get symptoms() {
    return this.form.get('symptoms') as FormArray<FormControl<string>>;
  }

  addSymptom() {
    this.symptoms.push(this.fb.control('', { nonNullable: true, validators: [Validators.required] }));
  }

  removeSymptom(index: number) {
    if (this.symptoms.length > 1) {
      this.symptoms.removeAt(index);
    }
  }

  async submit() {
    this.error = null;
    this.triageResult = null;
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const patientId = this.auth.getPatientId();
    const consent = this.auth.getConsentToken();
    if (!patientId || !consent) {
      this.error = 'Consent required before submitting symptoms.';
      return;
    }

    this.loading = true;
    const payload: SymptomPayload = {
      symptoms: this.symptoms.value.filter(Boolean),
      freeText: this.form.value.freeText ?? undefined,
      pregnancyFlag: this.form.value.pregnancyFlag,
    };

    try {
      if (!this.encounterId) {
        const created = await firstValueFrom(
          this.api.createEncounter(patientId, consent, 'web')
        );
        this.encounterId = created?.encounterId ?? null;
      }
      if (!this.encounterId) {
        throw new Error('Failed to create encounter.');
      }
      await firstValueFrom(this.api.submitSymptoms(this.encounterId, payload));
      const traceId = `trace-${Date.now()}`;
      this.triageResult = await firstValueFrom(this.api.triage(this.encounterId, traceId));
    } catch (err: any) {
      this.error = err?.message || 'Unable to complete triage. Please try again.';
    } finally {
      this.loading = false;
    }
  }
}

