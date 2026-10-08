const panel = document.getElementById('departmentPanel');
const vehicleList = document.getElementById('vehicleList');
const closeBtn = document.getElementById('closeBtn');
const app = document.getElementById('app');

let departments = [];
let selectedDepartment = null;

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
}

closeBtn.addEventListener('click', closeMenu);

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

function renderDepartments(data) {
    departments = data || [];
    panel.innerHTML = '';

    if (!departments.length) {
        panel.innerHTML = '<div style="padding: 12px; color: #a7b6c4;">No departments available.</div>';
        return;
    }

    selectedDepartment = departments[0].id;

    departments.forEach((department) => {
        const btn = document.createElement('button');
        btn.className = 'department-btn' + (department.id === selectedDepartment ? ' active' : '');
        btn.innerHTML = `
            <img class="department-icon" src="${department.image || ''}" alt="${department.label}" />
            <div class="department-label">${department.label}</div>
        `;

        btn.addEventListener('click', () => {
            selectedDepartment = department.id;
            renderDepartments(departments);
            renderVehicles(department);
        });

        panel.appendChild(btn);
    });

    renderVehicles(departments[0]);
}

function renderVehicles(department) {
    vehicleList.innerHTML = '';

    if (!department || !department.vehicles || !department.vehicles.length) {
        vehicleList.innerHTML = '<div style="padding: 12px; color: #a7b6c4;">No vehicles available.</div>';
        return;
    }

    department.vehicles.forEach((vehicle) => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';

        card.innerHTML = `
            <img class="vehicle-image" src="${vehicle.image || ''}" alt="${vehicle.label}" />
            <div class="vehicle-body">
                <h3 class="vehicle-title">${vehicle.label}</h3>
                <div class="vehicle-meta">
                    <span>${vehicle.model}</span>
                    <span>Limit: ${vehicle.spawnLimit || 0}</span>
                </div>
                <button class="spawn-btn" data-department="${department.id}" data-vehicle="${vehicle.id}">SPAWN</button>
            </div>
        `;

        const btn = card.querySelector('.spawn-btn');
        btn.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({
                    department: department.id,
                    vehicle: vehicle.id
                })
            });
        });

        vehicleList.appendChild(card);
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'openMenu') {
        app.classList.remove('hidden');
        renderDepartments(data.data || []);
    }

    if (data.action === 'closeMenu') {
        app.classList.add('hidden');
    }
});
