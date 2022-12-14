#include "Actor.as"
#include "Interpolation.as"
#include "Vec3f.as"
#include "Camera.as"
#include "Mouse.as"
#include "Ray.as"

shared class SpectatorActor : Actor, ICameraController
{
	Vec3f position;
	private Vec3f prevPosition;

	Vec3f rotation;
	private Vec3f prevRotation;

	private float moveSpeed = 0.5f;

	private CControls@ controls = getControls();
	private Camera@ camera = Camera::getCamera();
	private Mouse@ mouse = Mouse::getMouse();
	private Map@ map = Map::getMap();

	SpectatorActor(u16 id, CPlayer@ player, Vec3f position)
	{
		super(id, player);
		this.position = position;
		this.prevPosition = position;
	}

	u8 getType()
	{
		return EntityType::SpectatorActor;
	}

	void PreUpdate()
	{
		prevPosition = position;
		prevRotation = rotation;
	}

	void Init()
	{
		if (isMyActor())
		{
			camera.SetController(this);
		}
	}

	void Update()
	{
		if (isMyActor())
		{
			// Movement
			Vec2f dir;
			s8 verticalDir = 0;

			if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y++;
			if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y--;
			if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
			if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;
			if (controls.ActionKeyPressed(AK_ACTION3)) verticalDir++;
			if (controls.isKeyPressed(KEY_LSHIFT)) verticalDir--;

			float len = dir.Length();
			if (len > 0)
			{
				dir /= len; // Normalize
				dir = dir.RotateBy(rotation.y);
			}

			position.x += dir.x * moveSpeed;
			position.z += dir.y * moveSpeed;
			position.y += verticalDir * moveSpeed;

			// Rotation
			Vec2f mouseVel = mouse.getVelocity();
			rotation += Vec3f(mouseVel.y, mouseVel.x, 0);
			rotation.x = Maths::Clamp(rotation.x, -90, 90);
			rotation.z = Maths::Clamp(rotation.z, -90, 90);
			rotation.y = (rotation.y + 360.0f) % 360.0f;
		}
	}

	void Render()
	{
		if (isMyActor() && !g_videorecording)
		{
			float t = Interpolation::getFrameTime();
			Vec3f pos = prevPosition.lerp(position, t);
			GUI::DrawText(pos.toString(), Vec2f(10, 10), color_white);
		}
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		Actor::SerializeTickClient(bs);
		position.Serialize(bs);
		rotation.Serialize(bs);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		if (!Actor::deserializeTickClient(bs)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		return true;
	}

	void SerializeInit(CBitStream@ bs)
	{
		Actor::SerializeInit(bs);
		position.Serialize(bs);
		rotation.Serialize(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!Actor::deserializeInit(bs)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		return true;
	}

	Vec3f getCameraPosition()
	{
		return position;
	}

	Vec3f getCameraRotation()
	{
		return rotation;
	}
}
