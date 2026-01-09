import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-consent',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './consent.component.html',
  styleUrls: ['./consent.component.scss'],
})
export class ConsentComponent {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);

  form = this.fb.group({
    patientId: ['', Validators.required],
    consentToken: ['', Validators.required],
    acknowledged: [false, Validators.requiredTrue],
  });

  submit() {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const { patientId, consentToken } = this.form.value;
    this.auth.setConsent(patientId!, consentToken!);
    this.router.navigateByUrl('/patient/triage');
  }
}

