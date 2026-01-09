import { Component } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';
import { NgIf } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink, NgIf],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'Patient Triage CDS';
}
