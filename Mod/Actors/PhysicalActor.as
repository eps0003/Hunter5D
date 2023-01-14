#include "Actor.as"
#include "Interpolation.as"
#include "Vec3f.as"
#include "Camera.as"
#include "Mouse.as"
#include "Ray.as"
#include "AABB.as"
#include "ActorModel.as"
#include "PhysicalActorRunAnim.as"
#include "HealthHandler.as"
#include "INameplate.as"
#include "ICollisionHandler.as"
#include "BlockCollisionHandler.as"

shared class PhysicalActor : Actor, ICameraController, INameplate, IPhysics
{
	Vec3f position;
	private Vec3f prevPosition;
	Vec3f interPosition;

	Vec3f rotation;
	private Vec3f prevRotation;
	Vec3f interRotation;

	Vec3f velocity;
	private Vec3f prevVelocity;
	Vec3f interVelocity;

	private AABB@ collider;
	private ICollisionHandler@ collisionHandler;

	private ActorModel@ model;

	private u8 maxHealth = 10;
	private IHealthHandler@ healthHandler;

	private Vec3f cameraOffset = Vec3f(0, 1.6f, 0);

	private float acceleration = 0.08f;
	private float friction = 0.3f;
	private float jumpForce = 0.36f;
	private Vec3f gravity = Vec3f(0, -0.045f, 0);

	private CControls@ controls = getControls();
	private Camera@ camera = Camera::getCamera();
	private Mouse@ mouse = Mouse::getMouse();

	PhysicalActor(u16 id, CPlayer@ player, Vec3f position)
	{
		super(id, player);
		this.position = position;
		this.prevPosition = position;
		@healthHandler = HealthHandler(maxHealth);
		@collisionHandler = BlockCollisionHandler(this);
	}

	u8 getType()
	{
		return EntityType::PhysicalActor;
	}

	void Init()
	{
		SetCollider(AABB(Vec3f(-0.3f, 0, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));

		if (isClient())
		{
			@model = ActorModel("KnightSkin.png");
			model.SetAnimation(PhysicalActorRunAnim(this, model));
		}

		if (isMyActor())
		{
			camera.SetController(this);
		}
	}

	void PreUpdate()
	{
		prevPosition = position;
		prevRotation = rotation;
		prevVelocity = velocity;
	}

	void Update()
	{
		if (isMyActor())
		{
			Rotation();
			Movement();
		}
	}

	private void Rotation()
	{
		Vec2f mouseVel = mouse.getVelocity();
		rotation += Vec3f(mouseVel.y, mouseVel.x, 0);
		rotation.x = Maths::Clamp(rotation.x, -90, 90);
		rotation.z = Maths::Clamp(rotation.z, -90, 90);
		rotation.y = (rotation.y + 360.0f) % 360.0f;
	}

	private void Movement()
	{
		Vec2f dir;

		if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y++;
		if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y--;
		if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
		if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;

		float len = dir.Length();
		if (len > 0)
		{
			dir /= len; // Normalize
			dir = dir.RotateBy(rotation.y);
		}

		// Jumping
		if (collisionHandler.isOnGround() && controls.ActionKeyPressed(AK_ACTION3))
		{
			velocity.y = jumpForce;
		}

		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
	}

	void Render()
	{
		if (isClient())
		{
			float t = Interpolation::getFrameTime();
			interPosition = prevPosition.lerp(position, t);
			interVelocity = prevVelocity.lerp(velocity, t);
			interRotation = prevRotation.lerpAngle(rotation, t);
		}

		if (!isMyActor())
		{
			model.Render();
		}
	}

	void Draw()
	{
		if (isMyActor() && !g_videorecording)
		{
			GUI::DrawText(interPosition.toString(), Vec2f(10, 10), color_white);
		}
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		Actor::SerializeTickClient(bs);
		position.Serialize(bs);
		rotation.Serialize(bs);
		velocity.Serialize(bs);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		if (!Actor::deserializeTickClient(bs)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		if (!velocity.deserialize(bs)) return false;
		return true;
	}

	void SerializeInit(CBitStream@ bs)
	{
		Actor::SerializeInit(bs);
		position.Serialize(bs);
		rotation.Serialize(bs);
		velocity.Serialize(bs);
		gravity.Serialize(bs);
		healthHandler.SerializeInit(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		@healthHandler = HealthHandler(maxHealth);
		@collisionHandler = BlockCollisionHandler(this);

		if (!Actor::deserializeInit(bs)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		if (!velocity.deserialize(bs)) return false;
		if (!gravity.deserialize(bs)) return false;
		if (!healthHandler.deserializeInit(bs)) return false;
		return true;
	}

	void SerializeTick(CBitStream@ bs)
	{
		Actor::SerializeTick(bs);
		gravity.Serialize(bs);
		healthHandler.SerializeTick(bs);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		if (!Actor::deserializeTick(bs)) return false;
		if (!gravity.deserialize(bs)) return false;
		if (!healthHandler.deserializeTick(bs)) return false;
		return true;
	}

	AABB@ getCollider()
	{
		return collider;
	}

	void SetCollider(AABB@ collider)
	{
		@this.collider = collider;
	}

	bool hasCollider()
	{
		return collider !is null;
	}

	void DrawCrosshair(int spacing, int length, int thickness, SColor color)
	{
		Vec2f center = getDriver().getScreenCenterPos();

		Vec2f x1(length + spacing, thickness);
		Vec2f x2(spacing, -thickness);
		Vec2f y1(thickness, length + spacing);
		Vec2f y2(-thickness, spacing);

		//left/right
		GUI::DrawRectangle(center - x1, center - x2, color);
		GUI::DrawRectangle(center + x2, center + x1, color);

		//top/bottom
		GUI::DrawRectangle(center - y1, center - y2, color);
		GUI::DrawRectangle(center + y2, center + y1, color);
	}

	u8 getHealth()
	{
		return healthHandler.getHealth();
	}

	u8 getMaxHealth()
	{
		return healthHandler.getMaxHealth();
	}

	void SetHealth(u8 val)
	{
		healthHandler.SetHealth(val);
	}

	Vec3f getCameraPosition()
	{
		return position + cameraOffset;
	}

	Vec3f getCameraRotation()
	{
		return rotation;
	}

	string getNameplateText()
	{
		return getName();
	}

	Vec3f getNameplatePosition()
	{
		return interPosition + Vec3f(0.0f, collider.dim.y + 0.4f, 0.0f);
	}

	SColor getNameplateColor()
	{
		CTeam@ team = getRules().getTeam(getPlayer().getTeamNum());
		return team !is null ? team.color : color_white;
	}

	bool isNameplateVisible()
	{
		return !isMyActor();
	}

	Vec3f getPosition()
	{
		return position;
	}

	void SetPosition(Vec3f position)
	{
		this.position = position;
	}

	Vec3f getVelocity()
	{
		return velocity;
	}

	void SetVelocity(Vec3f velocity)
	{
		this.velocity = velocity;
	}

	Vec3f getGravity()
	{
		return gravity;
	}

	void SetGravity(Vec3f gravity)
	{
		this.gravity = gravity;
	}

	ICollisionHandler@ getCollisionHandler()
	{
		return collisionHandler;
	}

	void SetCollisionHandler(ICollisionHandler@ handler)
	{
		@collisionHandler = handler;
	}
}
