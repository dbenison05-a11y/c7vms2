const app = document.getElementById('app');
const departmentPanel = document.getElementById('departmentPanel');
const vehicleList = document.getElementById('vehicleList');
const closeBtn = document.getElementById('closeBtn');

let departments = [];
let selectedDepartment = null;
let selectedSubDepartment = null;
let adminFleet = [];
let adminReasons = [];
let adminStatusMap = {};

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
    departmentPanel.innerHTML = '';

    if (!departments.length) {
        departmentPanel.innerHTML = '<div class="empty-state">No departments available.</div>';
        return;
    }

    selectedDepartment = departments[0].id;
    selectedSubDepartment = departments[0].subDepartments && departments[0].subDepartments[0] ? departments[0].subDepartments[0].id : null;

    departments.forEach((department) => {
        const btn = document.createElement('button');
        btn.className = 'department-btn' + (department.id === selectedDepartment ? ' active' : '');
        btn.innerHTML = `
            <img class="department-icon" src="${department.image || ''}" alt="${department.label}" />
            <div class="department-label">${department.label}</div>
        `;

        btn.addEventListener('click', () => {
            selectedDepartment = department.id;
            selectedSubDepartment = department.subDepartments && department.subDepartments[0] ? department.subDepartments[0].id : null;
            renderDepartments(departments);
            renderVehiclePanel(department);
        });

        departmentPanel.appendChild(btn);
    });

    renderVehiclePanel(departments[0]);
}

function renderVehiclePanel(department) {
    vehicleList.innerHTML = '';
    if (!department || !department.subDepartments || !department.subDepartments.length) {
        vehicleList.innerHTML = '<div class="empty-state">No vehicles available.</div>';
        return;
    }

    department.subDepartments.forEach((subDepartment) => {
        const section = document.createElement('section');
        section.className = 'sub-department-section';

        const sectionHeader = document.createElement('div');
        sectionHeader.className = 'sub-department-header';
        sectionHeader.innerHTML = `
            <h3>${subDepartment.label}</h3>
        `;
        section.appendChild(sectionHeader);

        const list = document.createElement('div');
        list.className = 'vehicle-list';

        if (!subDepartment.vehicles || !subDepartment.vehicles.length) {
            list.innerHTML = '<div class="empty-state small">No vehicles in this division.</div>';
            section.appendChild(list);
            vehicleList.appendChild(section);
            return;
        }

        subDepartment.vehicles.forEach((vehicle) => {
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
                    <button class="spawn-btn" data-department="${department.id}" data-sub-department="${subDepartment.id}" data-vehicle="${vehicle.id}">SPAWN</button>
                </div>
            `;

            const spawnBtn = card.querySelector('.spawn-btn');
            spawnBtn.addEventListener('click', () => {
                fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify({
                        department: department.id,
                        subDepartment: subDepartment.id,
                        vehicle: vehicle.id
                    })
                });
            });

            list.appendChild(card);
        });

        section.appendChild(list);
        vehicleList.appendChild(section);
    });
}

function renderAdminFleet(data) {
    adminFleet = data || [];
    vehicleList.innerHTML = '';

    if (!adminFleet.length) {
        vehicleList.innerHTML = '<div class="empty-state">No fleet entries found.</div>';
        return;
    }

    adminFleet.forEach((entry) => {
        const card = document.createElement('div');
        card.className = 'fleet-card';

        const statusOptions = Object.values(adminStatusMap || {}).map((status) => {
            const selected = status === (entry.status || 'available') ? 'selected' : '';
            return `<option value="${status}" ${selected}>${status}</option>`;
        }).join('');

        const reasonOptions = (adminReasons || []).map((reason) => {
            const selected = reason === (entry.reason || '') ? 'selected' : '';
            return `<option value="${reason}" ${selected}>${reason}</option>`;
        }).join('');

        card.innerHTML = `
            <div class="fleet-header">
                <div>
                    <div class="fleet-label">${entry.label || entry.model || 'Vehicle'}</div>
                    <div class="fleet-small">${entry.plate || 'N/A'} • ${entry.department || 'Unknown'} / ${entry.subDepartment || 'Unknown'}</div>
                </div>
                <span class="status-badge">${entry.status || 'available'}</span>
            </div>
            <div class="fleet-controls">
                <label>
                    <span>Status</span>
                    <select class="fleet-status" data-plate="${entry.plate}">
                        ${statusOptions}
                    </select>
                </label>
                <label>
                    <span>Reason</span>
                    <select class="fleet-reason" data-plate="${entry.plate}">
                        <option value="">No reason</option>
                        ${reasonOptions}
                    </select>
                </label>
                <button class="update-btn" data-plate="${entry.plate}">Update</button>
            </div>
        `;

        const updateBtn = card.querySelector('.update-btn');
        updateBtn.addEventListener('click', () => {
            const plate = updateBtn.dataset.plate;
            const status = card.querySelector('.fleet-status').value;
            const reason = card.querySelector('.fleet-reason').value;

            fetch(`https://${GetParentResourceName()}/setVehicleStatus`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({
                    plate: plate,
                    status: status,
                    reason: reason || null
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
        departmentPanel.innerHTML = '';
        vehicleList.innerHTML = '';
        app.classList.remove('hidden');
        renderDepartments(data.data || []);
    }

    if (data.action === 'openAdminMenu') {
        departmentPanel.innerHTML = '';
        app.classList.remove('hidden');
        adminReasons = data.reasons || [];
        adminStatusMap = data.vehicleStatus || {};
        renderAdminFleet(data.fleetData || []);
    }

    if (data.action === 'closeMenu') {
        app.classList.add('hidden');
    }
});
